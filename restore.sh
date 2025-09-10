#!/bin/bash
# iPod Recovery Script
# Kyle Jett

# Crank up that output
exec 3>&1

# Send full output to logfile
exec &> >(tee "ipod-restore.log")

## Help output function
helpFunction()
{
	echo ""
	echo "iPod Restore Script"
	echo "Restores an iPod without needing iTunes"
	echo ""
	echo ""
	echo ""
	echo "Usage: $0 -d /dev/sda -m ./MBR/mbr-video80gb-2048.bin -f ./Firmware/Firmware-24.9.1.2 -c clean"
	echo ""
	echo -e "\t-d Specify which disk device to use. Example: -d /dev/sda"
	echo -e "\t-m Path to MBR image. Example: -m ./MBR/mbr-video80gb-2048.bin"
	echo -e "\t-f Extracted Firmware Path. Example: -f ./Firmware/Firmware-24.9.1.2"
	echo -e "\t-c Write zeros to first 1GB on disk. Usage: -c clean or -c wipe"
	echo ""
	exit 1 # Exit script after printing help
}

## 
while getopts "i:d:m:f:k:c:i:?" opt
do
    case "$opt" in
		i ) IPOD="$OPTARG" ;;
		d ) DISK="$OPTARG" ;;
		m ) MBR="$OPTARG" ;;
		f ) FIRMWARE="$OPTARG" ;;
		c ) CLEAN="$OPTARG" ;;
		? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
    esac
done

if [ "${CLEAN}" == "true" ]
then
  echo "Write zeros to first 1GB: True"
  ## Check again, if no DISK provided, then exit
  if [ -z "$DISK" ]
  then
    echo "No ipod device location provided."
    echo "Must provide iPod device location with -c wipe"
    echo "Example: sudo wipe.sh -d /dev/sda -c wipe"
    echo "Exiting..."
    echo ""
    exit 1
  fi
  echo ""
	echo "Writing zeros to first 1GB on disk ${DISK}"
	dd if=/dev/zero of=${DISK} bs=1024K count=1024
  exit
else
	echo ""
fi


echo ""
echo "iPod Recovery Script"
echo ""
echo "DISCLAIMER:"
echo "This script WILL wipe whatever disk location you provide it, even if it is not an iPod"
echo "Not responsible for dataloss or bricked devices."
echo "Dragons ahead, proceed with caution"
echo ""
sleep 2
echo "Make sure the iPod is in disk mode"
echo "Press MENU + SELECT to reboot the device and then"
echo "Press PLAY/PAUSE + Select once you see the Apple Logo"
echo ""
sleep 2
printf "%s " "Press enter to continue once the iPod is in disk mode"
read ans
echo ""

## Check status of DISK. If nothing is set, prompt for user input
if [ -z "$DISK" ]
then
	echo "Provide the location of the iPod device"
  echo "Example: /dev/sda"
	read DISK
	echo "You have selected ${DISK}"
	echo ""
  ## Check again, if no DISK provided, then exit
  if [ -z "$DISK" ]
  then
    echo "No ipod device location provided"
    echo "Exiting..."
    echo ""
    exit 1
  fi
fi

## Check status of IPOD. If nothing is set, prompt for user input
if [ -z "$IPOD" ]
then
	echo "Which iPod model are you restoring? example: gen6"
	echo "Leave blank to manually provide MBR and Firmware"
	read IPOD
	echo "You have selected ${IPOD}"
	echo ""
fi

## Check status of IPOD. If nothing is set, prompt for user input for MBR and Firmware
if [ -z "$IPOD" ]
then
	echo "No iPod model is set, please provide an MBR file and Firmware File"
	echo ""
	echo ""
	## Check status of MBR. If nothing is set, prompt for user input
	if [ -z "$MBR" ]
	then
		echo "Provide a path to an existing MBR partition image"
		echo "example: -m ./MBR/mbr-video80gb-2048.bin"
		read MBR
		echo "Using ${MBR} MBR image"
		echo ""
		if [ -z "$MBR" ]
    then
      echo "No MBR image provided"
      echo "Exiting..."
      echo ""
      exit 1
    fi
	fi

	## Check status of FIRMWARE. If nothing is set, prompt for user input
	if [ -z "$FIRMWARE" ]
	then
		echo "Provide a path to an existing MBR partition image"
		echo "example: -f ./Firmware/Firmware-24.9.1.2"
		read FIRMWARE
		echo "${FIRMWARE} will be used"
		echo ""
		if [ -z "$FIRMWARE" ]
    then
      echo "No firmware image provided"
      echo "Exiting..."
      echo ""
      exit 1
    fi
	fi

else
	case "$IPOD" in
		"gen6" )
			MBR=./MBR/mbr-video80gb-2048.bin
			FIRMWARE=./Firmware/Firmware-24.9.1.2 ;;
		"gen65" )
			MBR=./MBR/mbr-video80gb-2048.bin
			FIRMWARE=./Firmware/Firmware-24.9.1.2 ;;
		"gen7" )
			MBR=./MBR/mbr-video80gb-2048.bin
			FIRMWARE=./Firmware/Firmware-24.9.1.2 ;;
	esac
fi

# Check status of CLEAN. If nothing is set, set to skip
if [ -z "$CLEAN" ]
then
	CLEAN=skip
fi

echo "--------------------------------------------------"
echo ""
echo "Provided set values:"
echo ""
# if [ -z "${CONFIGFILE+x}" ] ## Need this to be if this exists then do this
# then
#   echo "No config file specified"
# else
# 	echo "Config File: ${CONFIGFILE}"
# fi

if [ -z "${IPOD}" ] ## Need this to be if this exists then do this
then
  echo "No iPod model specified"
else
	echo "iPod Version: ${IPOD}"
  case "$IPOD" in
		"gen6" )
			echo "iPod Classic 6G" ;;
		"gen65" )
			echo "iPod Classic 6.5G" ;;
		"gen7" )
			echo "iPod Classic 7G" ;;
	esac
fi
echo "Disk: ${DISK}"
echo "MBR: ${MBR}"
echo "Firmware: ${FIRMWARE}"
if [ "${CLEAN}" == "clean" ]
then
  echo "Write zeros to first 1GB: True"
else
	echo "Write zeros to first 1GB: False"
fi
echo ""
fdisk -l ${DISK}
echo ""
sleep 10

# Restore script
echo ""
echo "Starting iPod restore process. Make sure everything above looks good before continuing"
echo ""
printf "%s " "Press enter to continue"
read ans
echo ""

# Unmount all partitions
echo "Unmounting disk"
umount ${DISK}1
umount ${DISK}2
umount ${DISK}

# Check if CLEAN=clean. If it does, then scrub the first 1GB of the disk
if [ "${CLEAN}" == "clean" ]; then 
	#cleanup the first gig on disk
	echo ""
	echo "Writing zeros to first 1GB on disk ${DISK}"
	dd if=/dev/zero of=${DISK} bs=1024K count=1024
fi

# Copy MBR Partition Record from existing
echo ""
echo "Copying MBR partition record"
dd if=${MBR} of=${DISK}

# echo "Partitioning ${DISK}"
# parted ${DISK} -- mklabel msdos
# parted ${DISK} -- mkpart primary ext2 63s 64259s
# parted ${DISK} -- mkpart primary fat32 64260s 100%

# Reload Partition Table
echo ""
echo "Reloading the partition Table"
hdparm -z ${DISK}

# Output the disk layout to show after the MBR is written
echo ""
fdisk -l ${DISK}

# Load stock firmware
echo ""
echo "Loading the stock firmware to first partition"
dd if=${FIRMWARE} of=${DISK}1

#Create FAT32 Partition (storage)
echo ""
echo "Creating FAT32 partition with 2048b sector size"
mkfs.vfat -F 32 -S 2048 -n iPod ${DISK}2 -v

echo ""
fdisk -l ${DISK}

echo ""
echo "Ejecting iPod ${DISK}"
sync
eject ${DISK}
sleep 5

echo ""
echo "--------------------------------------------------"
echo "Finished restoring iPod"
echo ""
echo "Hold MENU and SELECT on ipod to finish the restore"
echo "When prompted to CONNECT TO POWER, make sure to plug in the iPod"
echo "Otherwise it will not finish updating the firmware"
echo ""
sleep 5
