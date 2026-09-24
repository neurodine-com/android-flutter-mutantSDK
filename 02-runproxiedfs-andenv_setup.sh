#!/usr/bin/env bash

# Author:          Blazej Kaczmarek
# ORCID:           https://orcid.org/0009-0003-1070-8870
# email:           blazej.kaczmarek@neurodine.com
# PEN OID:         1.3.6.1.4.1.53685
# PEN ASN.1:       {iso(1) identified-organization(3) dod(6) internet(1) private(4) enterprise(1) 53685}
# PEN OID url:     http://oid-info.com/get/1.3.6.1.4.1.53685
# Description:     I know this script looks strange but it simply runs it's OWN env aware checks.
# 						 If You cloned this repo then do not care about the mising env.local files etc.. I write scripts
# 							so that it is not needed and the script will collect it's own location - the directory where You will mount the 
#							proxied FS androidSDK files/resources.
# 						  Just run it and it will chew out a command to run so that it creates you the file that will be sourced 
# 							every time a shell is spawned and the ANDROID_HOME env variable will be set in env and will be added to the PATH env
# 
# 							Script will install in the directory from which it is executed the andoidSDK residing in 
# 							 the anoidsdk-proxyfs docker image, otherwise it can FAIL but only when the proxyfs image is corrupted.
# 							After script execution check it's status of success, like
# 								echo $?
#							where, 1 is BAD, 0 is GOOD.
# 							When 1 is echo'ed, then check if:
#								EXACTLY TWO exists in the proxyfs image: 
# 										1. */platform-tools
# 										2. */cmdline-tools/latest/bin
# 									If ANY of them is  not there then the SDK will not work for You/the code development for android
# 
# 							the .env.local file content is to store variable that holds name of DIR to use for SDK dir:

cat > ./.env.local <<-'MAKETHISTONAMETHEDIR_HEREDOC'
# :# if this variable is set then this will be the name of directory for sdk
export SDK_PREDICTED_DIRSNAME="androidsdk-proxyfs"
MAKETHISTONAMETHEDIR_HEREDOC


if [ -f ./.env.local ]; then
        source ./.env.local
fi

unset -f 'MAIN_ENVSETUPANDROIDSDK' 2>/dev/null || true;
function MAIN_ENVSETUPANDROIDSDK() {
set -- junkiesalwaysdopropersetup "$@"
shift;
typeset -a main_envsetupandroidsdk_args=()
main_envsetupandroidsdk_args=("$@")
typeset CRITIDIR="${CRITIDIR:-}"
typeset CRITIDIR="${CRITIDIR:-${main_envsetupandroidsdk_args[0]:-}}"
# if still nothing is found then the default|PREDICTED value is checked, that is androidsdk-proxyfs that is set in ./.emv.local file
# 	IF still this variable wiith PREDICTE name is not found then the current directory will be used as the ANDOID_HOME's value
typeset CRITIDIR="${CRITDIR:-$( [[ -d "${SDK_PREDICTED_DIRSNAME}" ]] && echo "${SDK_PREDICTED_DIRSNAME}" || ( tail -1 < <( mkdir -p -v "${SDK_PREDICTED_DIRSNAME}" ) ) )}"
typeset FOUND_CRITIDIR=""
typeset FOUND_WISEGUY=""
# for me important is to have the ABSOLUTE PATH to be set for the command that will set ACL for the dir
# PS. it will ONLY execute if the FOUND_CRITIDIR is not set at all, if You wish to have other dir to HOLD proxied fiel system of SDK location
# 	set the variable accordingly 
if [[ -n "${FOUND_CRITIDIR:=$( typeset CRITIDIR="${CRITIDIR:-.}" && env find "${CRITIDIR:+${CRITIDIR#/}/.}" -maxdepth 0 -type d -execdir pwd \; 2>/dev/null || :; )}" ]] &&
   [[ -n "${FOUND_WISEGUY:=$(env whoami 2>/dev/null)}" ]]; then
	unset -f 'maketheaclfix' 2>/dev/null || true;
	function maketheaclfix() {
		set -- junkiesalwaysconsumearguments "$@"; shift;
		typeset validenv_args_strings="$( \
			tr "${IFS#?}" "${IFS%${IFS#?}}" < <( \
				env find "${FOUND_CRITIDIR}" -mindepth 1 -maxdepth 3 \( -path '*/cmdline-tools/latest/bin' -prune \) -o \( -path '*/platform-tools' -prune \) 2>/dev/null  
			)
		)"
		if typeset -a validenv_args="(${validenv_args_strings})" &&
		   [[ $(( ${#validenv_args[@]} - 10#2 )) -eq 0 ]]; then
			( </dev/null 
				sudo setfacl -R -m u:${FOUND_WISEGUY}:rwx "${FOUND_CRITIDIR}" \
				&& sudo setfacl -R -d -m u:${FOUND_WISEGUY}:rwx "${FOUND_CRITIDIR}"
			) && ( \
				cat >&2 <<-'INFORMATION_TOSET_PATH_ACCORDINGLY_HEREDOC_PARTA'
# :# To store andoidSDK proxiedfs structure as Android SDK's ANDROID_HOME variable run
mkdir -p ~/.bashrc.d/ || :; ( cat > ~/.bashrc.d/"$(( 10#$(date +'%s') % 10#100 ))-load-ANDROIDHOME_SDK.sh" <<-'SAVE_ANDROIDSDK_CRITIPATH_HEREDOC'
INFORMATION_TOSET_PATH_ACCORDINGLY_HEREDOC_PARTA
                		( sed -r "$( printf 's|@FOUND_CRITIDIR@|%s|' "${FOUND_CRITIDIR}" )" ) >&2 <<-'INFORMATION_TOSET_PATH_ACCORDINGLY_HEREDOC_PARTB'
export ANDROID_HOME=@FOUND_CRITIDIR@
INFORMATION_TOSET_PATH_ACCORDINGLY_HEREDOC_PARTB
                		cat >&2 <<-'INFORMATION_TOSET_PATH_ACCORDINGLY_HEREDOC_PARTC'
# :# Android Platform tools critical PATH entries
# :# (with the important "latest" directory)
export PATH=${PATH:+${PATH}"$( printf '%s%s' ${ANDROID_HOME:+:${ANDROID_HOME}}{/cmdline-tools/latest/bin,/platform-tools} )"}
SAVE_ANDROIDSDK_CRITIPATH_HEREDOC
)
INFORMATION_TOSET_PATH_ACCORDINGLY_HEREDOC_PARTC
			     ) \
			  || ( ( echo "Failed to execute 'setfacl' for setting RWX permissions for dir:${FOUND_CRITIDIR}" | 2>&1 tee -a >&2 | systemd-cat ) || false )
			return
		fi
		false
	}; 
	if docker run -d --restart unless-stopped --rm -v "${FOUND_CRITIDIR}":/sdk_export myown-androidsdk-proxyfs; then
		if maketheaclfix ; then
			return	
		fi
	fi
false
fi
}; typeset -f -tx 'MAIN_ENVSETUPANDROIDSDK';

# THE MAIN function as always .. one must exists for shell to make things happen
# if You source this file.. then still all commends from heredoc will execute and will get into the environment
# 	if You run it normal (not souurce) then still it will do only checks and propose instructions to SAVE the cheks results
# 	the same as source but then ehe 

MAIN_ENVSETUPANDROIDSDK "$@"
