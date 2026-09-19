#!/usr/bin/env  bash

#
# getting the Android SDK from docker ... stupid native installer has issues with linux resourcess... welll - it's stupid
#

set -v && { \
		docker run -it --rm --device /dev/kvm androidsdk/android-31:latest bash 
	} || :;
set +v
cat >&2 <<-INFOON_CHECKINSTALLEDPACKAGES_HEREDOC
# :# check installed packages"
INFOON_CHECKINSTALLEDPACKAGES_HEREDOC
#
set -v && { \
		sdkmanager --list 
	 } || :;
set +v
#
cat >&2 <<-INFOON_CREATEANDRUNEMULATOR_HEREDOC
# :# create and run emulator
INFOON_CREATEANDRUNEMULATOR_HEREDOC
#
set -v && { \
	# :# this is the old .. orginal call for NOT updated android SDK
		#avdmanager create avd -n first_avd --abi google_apis/x86_64 -k "system-images;android-31;google_apis;x86_64"
	# this is the after update of android SDK to latest version: android devices android-36
		avdmanager create avd -n first_avd --abi google_apis/x86_64 -k "system-images;android-36;google_apis;x86_64"
		emulator -avd first_avd -no-window -no-audio &
		adb devices 
	} || :;
set +v
#
cat >&2 <<-INFOON_OTHER_TOOLS_HEREDOC
# :# You can also run other Android platform tools, which are all added to the PATH environment variable
# :# Thx. 
# :# This is the end
INFOON_OTHER_TOOLS_HEREDOC

