#!/usr/bin/env bash

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
