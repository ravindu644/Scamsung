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
	sudo apt update > /dev/null 2>&1
	sudo apt install simg2img make lz4 > /dev/null 2>&1
	compiling_lz4(){
		echo -e "\t\033[1;31mCompiling lz4...\033[0m\n"
		git clone https://github.com/lz4/lz4.git > /dev/null 2>&1
		cd lz4 && make > /dev/null && make install > /dev/null 2>&1
		cd "$WDIR"
	}
	compiling_lz4
	echo -e "\n\033[1;32mRequirements Installation Finished..!\033[0m"
}

variables(){
	echo -e "\033[1;37m[+] Enter your Device Name : \033[0m\n"
	read DEVICE_NAME 
	BASE_TAR_NAME="Base files - $DEVICE_NAME.tar"
}

get_link(){
	echo -e "\033[1;37m[i] Enter your firmware link [from samfw.com]: \n\033[0m"
	read FIRMWARE_LINK
}

directories(){
	cd "$WDIR"
	echo -e "\033[1;31m[+]Creating directories...\n\033[0m"
	mkdir Downloads Workplace output super
	echo -e "\033[1;32m[i]Done..!\033[0m"
}

downloading() {
    cd "$WDIR/Downloads" # Change directory
    get_link
    echo -e "\033[1;31m[+]Downloading firmware.zip...\n\033[0m"
    if wget "$FIRMWARE_LINK" -O firmware.zip --progress=bar:force --tries=3; then
        echo -e "\033[1;32m[i]Download Completed..!\033[0m"
    else
        echo -e "\033[1;31m[x]Error: Download failed. Enter a valid link :\033[0m"
        get_link
    fi
}

extracting(){
	cd "$WDIR/Downloads" # Change directory
	echo -e "\033[1;31m[+]Extracting the firmware Zip...\n\033[0m"
	unzip firmware.zip && rm firmware.zip
	tar -xf AP*.tar.md5 && tar -xf CSC*.tar.md5 && rm *.tar.md5 #extract and clean
	echo -e "\n\033[1;32m[i]Zip Extraction Completed..!\033[0m"
}

is_dynamic(){
	cd "$WDIR/Downloads" # Change directory
	if [ -e super.img.lz4 ]; then
		PARTITION_SCHEME=1
        	echo -e "\033[1;32m[i] Dynamic Partition Device Detected..!\033[0m"		
		IMG="super.img.lz4"
                CMD(){
                	mv $IMG "$WDIR/super"
                }

	elif [ -e system.img.lz4 ]; then
		PARTITION_SCHEME=2
        	echo -e "\033[1;32m[i] Non-Dynamic Partition Device Detected..!\033[0m"	
        	IMG="system.img.lz4"
                CMD(){
                        mv $IMG "$WDIR/super"
                        lz4 vendor.img.lz4 && lz4 product.img.lz4
                        mv vendor.img "$WDIR/super"
                        mv product.img "$WDIR/super"
                }

        else
                echo "An Internal Error occured..!"
                exit 1
        fi
}

base_files(){
	echo -e "\033[1;31m[+] Copying the Required files for Magisk/Developement...\033[0m"
	if [ "$PARTITION_SCHEME" == 1 ]; then
		cd "$WDIR/Downloads" #changed dir
		cp boot.img.lz4 vbmeta.img.lz4 recovery.img.lz4 dtbo.img.lz4 "$WDIR/output/"
		cd "$WDIR/output" #changed dir
		lz4 -d *.lz4
		rm *.lz4 #cleaning
		tar cvf "$BASE_TAR_NAME" boot.img vbmeta.img recovery.img dtbo.img; rm *.img #cleaning
	else
		cd "$WDIR/Downloads" #changed dir
		cp boot.img.lz4 vbmeta.img.lz4 recovery.img.lz4 dtbo.img.lz4 dt.img.lz4 "$WDIR/output/"
		cd "$WDIR/output" #changed dir
		lz4 -d *.lz4
		rm *.lz4 #cleaning
		tar cvf "$BASE_TAR_NAME" boot.img vbmeta.img recovery.img dtbo.img dt.img; rm *.img #cleaning
	fi
	zip "${BASE_TAR_NAME}.zip" "$BASE_TAR_NAME"
	rm "$BASE_TAR_NAME"
	echo -e "\033[1;32m[i] Zip file created: ${BASE_TAR_NAME}.zip\033[0m"
}

### EXTRACTING SYSTEM PARTITION ####

super_extract(){
	echo -e "\033[1;31m[+]Moving files to super directory...\n\033[0m"
	cd "$WDIR/Downloads"
	CMD
	cd "$WDIR/super" #changed dir
	echo -e "\033[1;32m[i]Cleaned up and you are now in the super directory !\n\033[0m"
	echo -e "\033[1;31m[+]Decompressing ${IMG}...\n\033[0m"
	lz4 "$IMG"
	rm "$IMG"
	echo -e "\n\033[1;32m[i]Decompression completed!\n\033[0m"

	if [ "$PARTITION_SCHEME" == 1 ]; then
		echo -e "\033[1;31m[+]Converting the super image to a RAW image...\n\033[0m"
		chmod +x "$WDIR/Scamsung/bin/simg2img"
		"$WDIR/Scamsung/bin/simg2img" super.img super.img.raw
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

cleanup(){
	cd "$WDIR"
	clear
	rm -rf Downloads Workplace output super
	echo -e "\033[1;32m[i]Cleaned..!\n\033[0m"
	sleep 2
	clear
	read -p "Wanna restart the Script ? (1,2) : " confirmation
	if [ "$confirmation" == 1 ]; then
		clear
		restart
	else
		echo "Good bye..!"
		exit 1
	fi
}

no_super(){
	echo -e "\033[1;31m[+] Making a Compressed Firmware package without Super/system...\033[0m"
	cd "$WDIR/Downloads"
	rm $IMG
	lz4 -d *.lz4
	rm *.lz4 #cleaning
	NON_SUPER="No ${IMG} + AP + CSC - ${DEVICE_NAME}"
	echo -e "\nChoose a compression method : \n1.ZIP (Faster) \n2.XZ (Slower, also lower size)"
	read -p "Enter value (1,2) : " super_compression
	
	input_no_super(){
		if [ "$super_compression" == 1 ]; then
			zip "${NON_SUPER}.zip" *.img
			mv "${NON_SUPER}.zip" "$WDIR/output"
		elif [ "$super_compression" == 2 ]; then
			tar -cvf "${NON_SUPER}.tar" *.img
			xz -9 --threads=0 "${NON_SUPER}.tar"
			mv "${NON_SUPER}.tar" "$WDIR/output"
		else
			echo "Wrong input..! Try Again..."
			input_no_super
		fi
	}
	input_no_super
	echo -e "\033[1;32m[i] Task completed and saved in ${WDIR}/output..!\n[i] Restarting the Script in 5 seconds..!"
	sleep 5
	cleanup
}

user_selection(){
	echo -e "\n\033[1;34m - Main menu -\033[0m"
	echo -e "\nWhat you want to do?\n\n1. Create a Base Zip file containing all the required files for Magisk\n2. Extracting the super.img or system.img\n3. Full firmware extraction.\n4. Extract the firmware without ${IMG} (Includes files from CSC and AP)\n5. Exit\n6. Cleanup."
	read -p "Choose a value (1,2,3,4,5) : " USER_INPUT

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
		base_files
		no_super	
	elif [ "$USER_INPUT" == 5 ]; then
		echo "Good bye..!"
		exit 1
	elif [ "$USER_INPUT" == 6 ]; then
		cleanup
	else
		echo -e "Wrong input..! Try Again"
		user_selection
	fi
}

restart(){
	banner
	dependencies
	variables
	directories
	downloading
	extracting
	is_dynamic
	user_selection
}

### STARTING SCRIPT HERE ###

banner
dependencies
variables
directories
downloading
extracting
is_dynamic
user_selection

# Copyright (c) [2023] [Ravindu Deshan]
