#!/bin/bash

################################################################################
# Copyright (c) [2023] [Ravindu Deshan]
#
# Unauthorized publication is prohibited. Forks and personal use are allowed.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
################################################################################
WDIR=$(pwd)
banner (){
	echo -e "\n\033[1;34mSamsung Firmware Extractor 2.0 - By Ravindu Deshan\033[0m"
	echo -e "\t\033[1;31mInstalling requirements...\033[0m\n"
}

dependencies() {
	#sudo apt update > /dev/null
	#sudo apt install simg2img > /dev/null
	compiling_lz4(){
		echo -e "\t\033[1;31mCompiling lz4...\033[0m\n"
		git clone https://github.com/lz4/lz4.git > /dev/null 2>&1
		cd lz4 && make > /dev/null && make install > /dev/null 2>&1
		sudo apt install lz4 > /dev/null 2>&1 #fix issues with gitpod
		cd "$WDIR"
	}
	compiling_lz4
	echo -e "\n\033[1;32mRequirements Installation Finished..!\033[0m"
}

variables(){
	echo -e "\033[1;37m[+] Enter your Device Name : \033[0m\n"
	read DEVICE_NAME 
	echo -e "\033[1;37m[i] Enter your firmware link [from samfw.com]: \n\033[0m"
	read FIRMWARE_LINK
	BASE_TAR_NAME="Base files - $DEVICE_NAME.tar"
}

is_dynamic(){
        echo -e "Which partition scheme your device have ?(1,2)\n\n 1. Dynamic partitions (super.img)\n 2. None-dynamic partitions (system.img)\n"
        read -p "Choose value (1,2) : " PARTITION_SCHEME
        if [ "$PARTITION_SCHEME" == 1 ]; then
                IMG="super.img.lz4"
                CMD(){
                        mv $IMG "$WDIR/Workplace"
                }
        elif [ "$PARTITION_SCHEME" == 2 ]; then
        		IMG="system.img.lz4"
                CMD(){
                        mv $IMG "$WDIR/Workplace"
                        lz4 vendor.img.lz4 && lz4 product.img.lz4
                        mv vendor.img "$WDIR/Workplace"
                        mv product.img "$WDIR/Workplace"
                }
        else
                echo "Invalid Input ! Try again..."
                is_dynamic
        fi
}

directories(){
	cd "$WDIR"
	echo -e "\033[1;31m[+]Creating directories...\n\033[0m"
	mkdir Downloads && mkdir Workplace && mkdir output
	echo -e "\033[1;32m[i]Done..!\033[0m"
}

downloading() {
    cd "$WDIR/Downloads" # Change directory
    echo -e "\033[1;31m[+]Downloading firmware.zip...\n\033[0m"
    
    # Use wget with --tries to limit the number of retries
    if wget "$FIRMWARE_LINK" -O firmware.zip --progress=bar:force --tries=3; then
        echo -e "\033[1;32m[i]Download Completed..!\033[0m"
    else
        # Print an error message and exit the script
        echo -e "\033[1;31m[x]Error: Download failed.\033[0m"
        exit 1
    fi
}

extracting(){
	echo -e "\033[1;31m[+]Extracting the firmware Zip...\n\033[0m"
	unzip firmware.zip && rm firmware.zip
	tar -xf AP*.tar.md5 && tar -xf CSC*.tar.md5 && rm *.tar.md5 #extract and clean
	echo -e "\n\033[1;32m[i]Zip Extraction Completed..!\033[0m"
}

base_files(){
	echo -e "\033[1;31m[+] Copying the Required files for Magisk/Developement...\033[0m"
	if [ "$PARTITION_SCHEME" == 1 ]; then
		cd "$WDIR/Downloads" #changed dir
		cp boot.img.lz4 vbmeta.img.lz4 recovery.img.lz4 dtbo.img.lz4 "$WDIR/output/"
		cd "$WDIR/output" #changed dir
		lz4 boot.img.lz4
		lz4 vbmeta.img.lz4
		lz4 recovery.img.lz4
		lz4 dtbo.img.lz4
		rm *.lz4 #cleaning
		tar cvf "$BASE_TAR_NAME" boot.img vbmeta.img recovery.img dtbo.img; rm *.img #cleaning
	else
		cd "$WDIR/Downloads" #changed dir
		cp boot.img.lz4 vbmeta.img.lz4 recovery.img.lz4 dtbo.img.lz4 dt.img.lz4 "$WDIR/output/"
		cd "$WDIR/output" #changed dir
		lz4 boot.img.lz4
		lz4 vbmeta.img.lz4
		lz4 dt.img.lz4
		lz4 recovery.img.lz4
		lz4 dtbo.img.lz4
		rm *.lz4 #cleaning
		tar cvf "$BASE_TAR_NAME" boot.img vbmeta.img recovery.img dtbo.img dt.img; rm *.img #cleaning
	fi
	zip "${BASE_TAR_NAME}.zip" "$BASE_TAR_NAME"
	rm "$BASE_TAR_NAME"
	echo -e "\033[1;32m[i] Zip file created: ${BASE_TAR_NAME}.zip\033[0m"
}

### EXTRACTING SYSTEM PARTITION ####

super_extract(){
	echo -e "\033[1;31m[+]Moving files to Workplace directory...\n\033[0m"
	cd "$WDIR/Downloads"
	CMD
	cd "$WDIR/Workplace" #changed dir
	echo -e "\033[1;32m[i]Cleaned up and you are now in the Workplace directory !\n\033[0m"
	echo -e "\033[1;31m[+]Decompressing ${IMG}...\n\033[0m"
	lz4 "$IMG"
	rm "$IMG"
	echo -e "\n\033[1;32m[i]Decompression completed!\n\033[0m"

	if [ "$PARTITION_SCHEME" == 1 ]; then
		echo -e "\033[1;31m[+]Converting the super image to a RAW image...\n\033[0m"
		"$WDIR/bin/simg2img" super.img super.img.raw
		rm super.img
		echo -e "\033[1;32m[i]Conversion completed!\n\033[0m"
		echo -e "\033[1;32m[i]Your super partition size is : $(stat -c '%n %s' super.img.raw) bytes\n\033[0m"
		echo -e "\033[1;31m[+]Extracting system, vendor, product, odm partitions from super.img.raw...\n\033[0m"
		chmod +x "$WDIR/Scamsung/bin/lpunpack"
		"$WDIR/Scamsung/bin/lpunpack" super.img.raw && rm super.img.raw
		echo -e "\n\033[1;32m[i]Extraction completed!\033[0m"
	else
		echo -e "\033[1;32m[i]Your System partition size is : $(stat -c '%n %s' system.img) bytes\n\033[0m"

	fi
}

repacking(){
	echo -e "\033[1;31m[+]Creating System TAR file...\n\033[0m"
	TAR_NAME="System - $DEVICE_NAME.tar"
	if [ "$PARTITION_SCHEME" == 1 ]; then
		tar cf "$TAR_NAME" system.img vendor.img odm.img product.img
	else
		tar cf "$TAR_NAME" system.img vendor.img product.img
	fi
	echo -e "\nChoose a compression method\n1.ZIP\n2.TAR.XZ (Slower)"
	read -p "Enter value (1,2) : " compression_method
	
	compression_method_input(){
		if [ "$compression_method" == 2 ]; then
			echo -e "\n[i] Compressing objects using XZ compression.."
			xz -9 --threads=0 "$TAR_NAME"
			echo -e "\033[1;32m[i]TAR file created: ${TAR_NAME}.xz\n\033[0m"
			echo -e "\033[1;31m[+]Moving TAR file to Output...\n\033[0m" && mv "${TAR_NAME}.xz" "$WDIR/output"
		elif [ "$compression_method" == 1 ]; then
			echo -e "\n[i] Compressing objects using ZIP compression.."
			zip -r "${TAR_NAME}.zip" "$TAR_NAME"
			echo -e "\033[1;32m[i]ZIP file created: ${TAR_NAME}.zip\n\033[0m"
			echo -e "\033[1;31m[+]Moving TAR file to Output...\n\033[0m" && mv "${TAR_NAME}.zip" "$WDIR/output"
		else
			echo -e "Invalid Input. Try Again..!"
			compression_method_input
		fi
	}
	compression_method_input
	echo -e "\033[1;32m[i]Firmware extraction for device ${DEVICE_NAME} is completed!"
}

user_selection(){
	echo -e "\n\033[1;34m - Main menu -\033[0m"
	echo -e "\nWhat you want to do?\n\n1. Create a Base Zip file containing all the required files for Magisk\n2. Extracting the super.img or system.img\n3. Full firmware extraction.\n4.Exit"
	read -p "Choose a value (1,2,3,4) : " USER_INPUT

	if [ "$USER_INPUT" == 1 ]; then
		base_files
		user_selection
	elif [ "$USER_INPUT" == 2 ]; then
		super_extract
		repacking
		user_selection
	elif [ "$USER_INPUT" == 3 ]; then
		base_files
		super_extract
		repacking
		user_selection
	elif [ "$USER_INPUT" == 4 ]; then
		echo "Good bye..!"
		exit 1
	else
		echo -e "Wrong input..! Try Again"
		user_selection
	fi
}

### STARTING SCRIPT HERE ###

banner
dependencies
variables
is_dynamic
directories
downloading
extracting
user_selection

# Copyright (c) [2023] [Ravindu Deshan]
