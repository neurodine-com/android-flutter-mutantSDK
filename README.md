# android-flutter-mutantSDK
This is a description of my TRIAL on making VSCode remote sessin to work on project in Flutter (dart) to use androidSDK without /dev/kvm capable computer and reuse dockered androidsdk-31 data.

Initial problem: Lack of hardware support for virtualization (KVM) on older hardware prevents starting the Android emulator and SDK containers on the fly.

Step 1: Extract a clean SDK from Docker

Use the androidsdk/android-31 docker image and run it once with a mounted volume to "export" the directory structure to the host:

docker run --rm -v ~/Android/Sdk-export:/data_wyjsciowa androidsdk/android-31:latest bash -c "cp -a /opt/android-sdk-linux/. /data_wyjsciowa/"

Step 2: Clean permissions (No root chown)

Apply setfacl with the -d (default) flag to preserve the file structure while giving full rights to the user and automatically assigning them for future updates:

sudo setfacl -R -m u:$USER:rwx ~/Android/Sdk-export
sudo setfacl -R -d -m u:$USER:rwx ~/Android/Sdk-export

Step 3: Hooking it up with Flutter and updating

Point to the SDK path using the flutter config --android-sdk command and download the missing tool versions via the exported sdkmanager.
Step 4: udev and group setup for a physical phone

Install the android-sdk-platform-tools-common package, add the user to the plugdev group, and restart the machine/service to enable USB debugging authorization on older Linux.
