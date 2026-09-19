# q: What this is for?
# a: I want to copy androidsdk FS structure (files + folders) to my own location and mount it as docker image
	
# Work on the andoidsdk image of the choice
FROM androidsdk/android-31:latest

# mount point for the files on this HOST that is a filesystemproxy docker host
VOLUME /sdk_export

# we change default image behaviour - on the startm it should simply copy file contents
CMD ["sh", "-c", "cp -a /opt/android-sdk-linux/. /sdk_export/"]

