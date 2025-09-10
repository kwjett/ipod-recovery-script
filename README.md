# ipod-recover-script

A simple script to recover iPods to factory firmware without iTunes
This script only works on Linux due to limitations with MacOS Disk Utility not being able to see the first partition.

This is based on fragments of information and research from attempting to install Rockbox on my iPod Classic 6G.

Based on the mbr images and information from here the following URLs
https://www.rockbox.org/wiki/IpodConversionToFAT32
https://www.rockbox.org/wiki/IpodManualRestore.html
https://blog.kimiblock.top/2024/09/05/ipod-on-linux/index.html


## Disclaimer:
Not responsible for bricking your device. Use at your own risk.

### Limitations:
Currently this works if you want to use stock firmware, but there is some issues with Rockbox not playing nicely.
Once I have this resolved I will remove this  from the disclaimer

## Usage:
```
Usage: sudo ./wipe.sh -i gen6 -d /dev/sda

Usage: sudo ./wipe.sh -d /dev/sda -m ./MBR/mbr-video80gb-2048.bin -f ./Firmware/Firmware-24.9.1.2 -k clean

  -i Specify which iPod model you are using. Automatically selects MBR and Firmware 
	-d Specify which disk device to use. Example: -d /dev/sda
	-m Path to MBR image. Example: -m ./MBR/mbr-video80gb-2048.bin
	-f Extracted Firmware Path. Example: -f ./Firmware/Firmware-24.9.1.2
	-k Write zeros to first 1GB on disk. Usage: -k skip or clean
	-c Specify a path to a config file to source
	-v Verbose output
```

## Instructions

### Make sure the iPod is in Disk Recovery Mode (not DFU mode)

To get the device into disk mode do the following:
Hold down MENU + SELECT until the Apple Logo appears, then quickly release and hold PLAY/PAUSE + SELECT

If you do this correctly it will boot into a black and white screen saying it is in disk mode.

### Check the location that the iPod gets mounted on

Make note of the location that the iPod is mounted on the system.
For me this was `/dev/sda` but you may find it is mounted at a different device location. 

Search for the disk with fdisk -l
```
sudo fdisk -l
```

or you can use lsblk
```
lsblk
```

### Run the wipe.sh script

Specify iPod model and device path:
```
sudo ./wipe.sh -i gen6 -d /dev/sda
```

Possible options for ipod models are as follows:

gen6 = iPod Classic 80/160 GB Thick model
gen65 = iPod Classic 120GB Thin model
gen7 = iPod Classic 160gb Thin Model

## Advanced use cases

### Specify MBR and Firmware file manually

Usage:
```
sudo ./wipe.sh -d /dev/sda -m ./MBR/mbr-video80gb-2048.bin -f ./Firmware/Firmware-24.9.1.2
```
Note that we do not specify the iPod version using this method.

### Clean the 1st 1GB of space prior to restoring
This is for when you screw up and Rockbox isn't happy about that first paritition.

Usage:
```
sudo ./wipe.sh -d /dev/sda -m ./MBR/mbr-video80gb-2048.bin -f ./Firmware/Firmware-24.9.1.2 -k clean
```
or 
```
sudo ./wipe.sh -i gen6 -d /dev/sda -m -k clean
```

### Extracting Firmware from .ipsw file
Firmware can be easily be extracted since the ipsw file is just a zip format with a different extension.

#### On Linux
```
unzip iPod_24.1.1.2.ipsw
```

#### On Windows or Mac
Rename the file change the .ipsw extension to .zip
Unzip with WinZip or similar