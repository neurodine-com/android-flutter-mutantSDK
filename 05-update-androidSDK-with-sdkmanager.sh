# :# old usecase with deprecated "sdkmanage" tool ;
# sdkmanager "build-tools;28.0.3" "platforms;android-36"
# :# new valid way using "android-cli" ;
# to have android-cli run 07-postupdate-androidcli.sh script
android sdk install "build-tools;28.0.3" "platforms;android-36"
