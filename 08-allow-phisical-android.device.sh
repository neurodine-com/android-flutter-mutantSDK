# :# this is needed for ALLOWING on Linux a device to have permission - to modify udev rules on linux
sudo apt update && sudo apt install -y android-sdk-platform-tools-common
# :# afterwards do udev restart
# :# check the current status
sudo systemctl status udev 

# :# restart udev and afterwads verify it's status
sudo systemctl restart udev

sudo journalctl -xe --unit=udev --follow
