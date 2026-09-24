# android-flutter-mutantSDK

This is a successfull attempt to develope and build in VSCode a Flutter[^theflutterframework] project.
Idea is to code/create a App (kind of a ~Game) using a Flutter[^theflutterframework] that runs smoothly on:
   +Android
   +Windows
   +Linux
   +WebBrowser
   +MacOS
   +iOS

What turned out to be the main problem maker was the AndroidSDK installation (hefty and strange restrictions).

I have a Very Old miniPC and no VT/KVM avaiability. Nothing that can run Android device emulation.

---
## Workplace introduction:  
1.Develompment host:

   **_12 years old miniPC_** (HDD:256GB SSD, RAM:12GB DDR, CPU:Intel Celeron)[^devhostinfo]  
   It is a **Remote** host on LAN, _Linux Mint_[^osversion] with No Graphical Target 
   > (graphics makes to much cpu lags)  

   +miniPC's BIOS has no virtualisation:  
   >No emulation device is the CORE issue.  
   >No target to deploy/debug/test App in a Android device.  
   
   `flutter doctor` - reports missing /dev/kvm

    Solution is: A Phisical Android device _(Developer On)_ on USB cable wired with miniPC
   
2.Development workspace:

   -VSCode Server on Remote host (miniPC), ssh boundry set on miniPC's wrokspace local directory 
   >No _Android Studio_ | It makes my miniPC weep  
   
   -Flutter, Dart - VSCode extension
      +3.47.4 Flutter SDK
      +3.13.3 (Flutter) - Dart SDK
   -Java openJDK 25 LTS for Gradle 
   

3.Problems:  

   +AndroidSDK missing
      -Native **AndroidSDK** installer fails to start/complete due to resource, no-virtualisation.  
      -androidSDK from tar.gz relative files usually fail on dir/files structure, requirements+updates

   +`flutter doctor` reports no GTK dev libs from i386 architecture (??)
   +docker androidSDK/**android-31**[^androidsdkdockerurl] is the max version I found, where **android-36** is the goal
   >Instructions to run docker'ed androidSDK image FAIL -> **no /dev/kvm**. Different way's of running dockered androidSDK image, runs a container that fails to create emulated device :-(
   
   Summary:

      ..harsh for miniPC. AndroidSDK avaiability:

      +~EXE installers fail on start or fail in update-maintanance.  
      +TAR do the same as EXE in genneral or fail to update providing missing sub-components
      +docker container has no use -> NO /dev/kvm  
      > <https://hub.docker.com/r/androidsdk/android-31>



4.Solution:

   Create a proxy file system docker image from a LATEST docker image of androidSDK.  
   Idea is Not to RUN the docker androidSDK image, but to use it's FS's dir structure and files in OFFLINE mode.  
   To do a proxy file system I made a local build of custom Dockerfile image that exposes it's stored files as volumes to miniPC's FS.
   Dockerfile that is builds localy takes as datasource the androidSDK image storred data.

   1.First pull the androidSDK/android-31:latest image: `docker pull androidsdk/android-31`  
   2.Create Dockerfile with the use of below code


   ```Bash
cat >Dockerfile <<-'THISISNICE_DOCKER_TO_DOCKER_COPY_HEREDOC'
# q: What this is for?
# a: I want to copy androidsdk FS structure (files + folders) to my own location and mount it as docker image

# Work on the andoidsdk image of the choice
FROM androidsdk/android-31:latest

# mount point for the files on this HOST that is a filesystemproxy docker host
VOLUME /sdk_export

# we change default image behaviour - on the startm it should simply copy file contents
CMD ["sh", "-c", "cp -a /opt/android-sdk-linux/. /sdk_export/"] 
THISISNICE_DOCKER_TO_DOCKER_COPY_HEREDOC
   ```  
   3. Build the andoirdsdk-proxyfs image: `docker build -t myown-androidsdk-proxyfs .`

   >Most increadible thing is that the source image from dockerhub is fiew Gigs and the build command makes the proxyfs image in fiew secs!. On my miniPC it took less then 4 secs to complete!  

   4.Use the andoidsdk-proxyfs image.  
   Run script from repository in shell: 02-runproxiedfs-andenv_setup.sh.

   >To not BRAKE any dir or file structure from mounted docker image columes, use the **setfacl** commands below.
```bash
typeset MEBENOTUSER="${MEBENOTUSER:=$(whoami)}" && ( \
  sudo setfacl -R -m u:${MEBENOTUSER}:rwx ./androidsdk-proxyfs
  sudo setfacl -R -d -m u:${MEBENOTUSER}:rwx ./androidsdk-proxyfs 
)
```

   Afterwards, step into _${ANDROID_HOME}/cmdline-tools/latest/bin_ and accept the license agreenment (read it ...:-)  
   To get with it much faster then typing or waiting for text, do:
```bash
yes y | sdkmanager --licenses
```
   When this is DONE, You are almost there, just the update from android-31 to android-36.  
   The `flutter doctor` when run, should now present LESS problems and if ANY, the solution's are staight-forward.  

   Instructions to complete androidSDK update && upgrade (no root required for androidSDK):

```
sdkmanager "build-tools;28.0.3" "platforms;android-36"
```

   when done, again accept license like before  

   In case `flutter doctor` present issues, do a broad upgrade, like so:
      +sdkmanager upgrade

   When completed. accept license again and do not care if emulator data got installed elsewhere in your OS.  
   You/Me will not use it at all as I have no KVM/VT support in miniPC.


===
Footnotes   

[^androidsdkdockerurl]:
   <https://hub.docker.com/r/androidsdk/android-31>


[^theflutterframework]:
  Flutter framework and develope in Dart language  
  Both Flutter and Dart are installed as VSCode extensions


[^osversion]:
  ```Bash
  uname -vro
  ```
  >6.8.0-106-generic #106-**Ubuntu** SMP PREEMPT_DYNAMIC Fri Mar  6 07:58:08 UTC 2026 GNU/Linux


[^devhostinfo]:
  os: Linux Mint, SSD: 256GB, RAM: 12GB DDR, CPU: 2xCore Celeron  
  ```BASH
  grep -iE '^((model name)|(vendor_id))[[:blank:]]+:.*$' < <(</proc/cpuinfo)
  ```
  >vendor_id       : GenuineIntel  
  >model name      : Intel(R) Celeron(R) 2957U @ 1.40GHz  
  >vendor_id       : GenuineIntel  
  >model name      : Intel(R) Celeron(R) 2957U @ 1.40GHz  


