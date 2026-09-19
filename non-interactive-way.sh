#!/usr/bin/env bash


cat >&2 <<-INFOON_CHECKINGINSTALLEDPACKAGES_HEREDOC
# :# check installed packages
INFOON_CHECKINGINSTALLEDPACKAGES_HEREDOC
#
set -v && { \
		 docker run -it --rm androidsdk/android-31:latest sdkmanager --list
	} || :;
set +v
#
cat >&2 <<-INFOON_LISTINGEXISTINGEMULATORS_HEREDOC
# :# list existing emulators
INFOON_LISTINGEXISTINGEMULATORS_HEREDOC
set -v && { \
		docker run -it --rm androidsdk/android-31:latest avdmanager list avd
	} || :;
set +v
#
cat >&2 <<-INFOON_OTHERTOOLSTHATAREONPATH_HEREDOC
# :# You can also run other Android platform tools, which are all added to the PATH environment variable
INFOON_OTHERTOOLSTHATAREONPATH_HEREDOC
#
