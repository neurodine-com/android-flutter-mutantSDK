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
   A VSCode's remote ssh session bound to Flutter's project dir 
   >_Android Studio makes my miniPC weep_  

   Native **AndroidSDK** installer fails to start/complete due to resource, no-virtualisation



### Step 1: Extract a clean SDK from Docker

Use the androidsdk/android-31 docker image and run it once with a mounted volume to "export" the directory structure to the host:
```docker run --rm -v ~/Android/Sdk-export:/data_wyjsciowa androidsdk/android-31:latest bash -c "cp -a /opt/android-sdk-linux/. /data_wyjsciowa/"```

#### Step 2: Clean permissions (No root chown)

Apply setfacl with the -d (default) flag to preserve the file structure while giving full rights to the user and automatically assigning them for future updates:
```BASH
sudo setfacl -R -m u:$USER:rwx ~/Android/Sdk-export
sudo setfacl -R -d -m u:$USER:rwx ~/Android/Sdk-export
```
#### Step 3: Hooking it up with Flutter and updating

Point to the SDK path using the flutter config --android-sdk command and download the missing tool versions via the exported sdkmanager.
#### Step 4: udev and group setup for a physical phone

Install the android-sdk-platform-tools-common package, add the user to the **_plugdev_** os unix group,
 and restart the machine/service to enable USB debugging authorization on older Linux.

[^theflutterframework]:
  Flutter framework and develope in Dart language  

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


