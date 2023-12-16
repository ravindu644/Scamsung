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
	echo -e "\n\033[1;34mSamsung Firmware Extractor 3.0 - By Ravindu Deshan\033[0m"
	echo -e "\t\033[1;31mInstalling requirements...\033[0m\n"
}

dependencies() {
	sudo apt update > /dev/null 2>&1
	sudo apt install simg2img make lz4 openssl python3 python-is-python3 > /dev/null 2>&1
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
	rm -rf Downloads Workplace output super recovery 
	echo -e "\033[1;31m[+] Creating directories...\n\033[0m"
	mkdir Downloads Workplace output super recovery > /dev/null 2>&1
	echo -e "\033[1;32m[i] Done..!\033[0m"
}

downloading() {
    cd "$WDIR/Downloads" # Change directory
    get_link
    echo -e "\033[1;31m[+] Downloading firmware.zip...\n\033[0m"
    if curl -# -o firmware.zip "$FIRMWARE_LINK" --retry 3; then
        echo -e "\033[1;32m[i] Download Completed..!\033[0m"
    else
        echo -e "\033[1;31m[x] Error: Download failed. Enter a valid link :\033[0m"
        get_link
    fi
}

extracting(){
	cd "$WDIR/Downloads" # Change directory
	echo -e "\033[1;31m[+] Extracting the firmware Zip...\n\033[0m"
	unzip firmware.zip && rm firmware.zip

	for file in *.tar.md5; do
    	tar -xvf "$file" && rm "$file"
	done

	if [ -e "$WDIR/Downloads/recovery.img.lz4" ]; then
		cp "$WDIR/Downloads/recovery.img.lz4" "$WDIR/recovery"
	else
		cp "$WDIR/Downloads/recovery.img" "$WDIR/recovery"
	fi
	echo -e "\n\033[1;32m[i]Zip Extraction Completed..!\033[0m"

	chk_lz4(){	    
	    files=$(find . -name "*.lz4")
	    if [ -n "$files" ]; then
	        echo -e "\n\033[1;32m\n[i]Decompressing LZ4 files...\033[0m\n"
	        lz4 -m *.lz4 > /dev/null 2>&1
			rm *.lz4 #cleaning
	    fi
	}

	chk_lz4
}

is_dynamic(){
	cd "$WDIR/Downloads" # Change directory
	if [ -e super.img ]; then
		PARTITION_SCHEME=1
        	echo -e "\033[1;32m[i] Dynamic Partition Device Detected..!\033[0m"		
		IMG="super.img"
                CMD(){
                	mv $IMG "$WDIR/super"
                }

	elif [ -e system.img ] && [ -e vendor.img ]; then
		PARTITION_SCHEME=2
        	echo -e "\033[1;32m[i] Non-Dynamic Partition Device Detected..!\033[0m"	
        	IMG="system.img"
                CMD(){
                        mv $IMG "$WDIR/super"
                        mv vendor.img "$WDIR/super"
                        mv product.img "$WDIR/super"
                }

    elif [ -e system.img ] || [ -e system.img.ext4 ] && [ ! -e vendor.img ] ; then
    	is_legacy=1
        CMD(){
        	echo -e "\n\033[1;32mCurrently only supports Base files extracting for Legacy Devices..!\033[0m\n"
        	sleep 2
        	echo -e "\033[1;32m[i] Restarting..!\033[0m"
        	sleep 2
        	user_selection
        }    	

    else
        echo "An Internal Error occured..!"
        exit 1
    fi
}

LCMD(){
	if [ "$is_legacy" == 1 ]; then
	    echo -e "\n\033[1;32mCurrently only supports Base files extracting for Legacy Devices..!\033[0m\n"
    	sleep 2
    	echo -e "\033[1;32m[i] Restarting..!\033[0m"
    	sleep 2
    	user_selection
    fi
}

recovery_patch(){
	echo -e "\n\033[1;31m[+] Patching the recovery to get Fastbootd back..!\n\033[0m"
	chmod a+x $WDIR/Scamsung/bin/*
	cd "$WDIR" && cd recovery
	cp "$WDIR/Downloads/recovery.img" .	
	if [ -f recovery.img.lz4 ];then
		lz4 -B6 --content-size -f recovery.img.lz4 recovery.img
	fi

	off=$(grep -ab -o SEANDROIDENFORCE recovery.img |tail -n 1 |cut -d : -f 1)
	dd if=recovery.img of=r.img bs=4k count=$off iflag=count_bytes

	if [ ! -f phh.pem ];then
	    openssl genrsa -f4 -out phh.pem 4096
	fi

	mkdir unpack
	cd unpack
	$WDIR/Scamsung/bin/magiskboot unpack ../r.img
	$WDIR/Scamsung/bin/magiskboot cpio ramdisk.cpio extract
	# Reverse fastbootd ENG mode check
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery e10313aaf40300aa6ecc009420010034 e10313aaf40300aa6ecc0094 # 20 01 00 35
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery eec3009420010034 eec3009420010035
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 3ad3009420010034 3ad3009420010035
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 50c0009420010034 50c0009420010035
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 080109aae80000b4 080109aae80000b5
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 20f0a6ef38b1681c 20f0a6ef38b9681c
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 23f03aed38b1681c 23f03aed38b9681c
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 20f09eef38b1681c 20f09eef38b9681c
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 26f0ceec30b1681c 26f0ceec30b9681c
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 24f0fcee30b1681c 24f0fcee30b9681c
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 27f02eeb30b1681c 27f02eeb30b9681c
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery b4f082ee28b1701c b4f082ee28b970c1
	$WDIR/Scamsung/bin/magiskboot hexpatch system/bin/recovery 9ef0f4ec28b1701c 9ef0f4ec28b9701c
	$WDIR/Scamsung/bin/magiskboot  cpio ramdisk.cpio 'add 0755 system/bin/recovery system/bin/recovery'
	$WDIR/Scamsung/bin/magiskboot  repack ../r.img new-boot.img
	mv new-boot.img ../recovery-patched.img; cd ..

        python3 "$WDIR/Scamsung/bin/avbtool" extract_public_key --key phh.pem --output phh.pub.bin
        python3 "$WDIR/Scamsung/bin/avbtool" add_hash_footer --partition_name recovery --partition_size $(wc -c recovery.img |cut -f 1 -d ' ') --image recovery-patched.img --key phh.pem --algorithm SHA256_RSA4096
        mv recovery-patched.img "$WDIR/output/recovery.img"
        #tar cvf fastbootd-recovery.tar "$WDIR/output/recovery.img"
        echo -e "\033[1;32m\n[i] Patching Done..!\n"
        cd "$WDIR/output" #changed dir

}

base_files(){
	echo -e "\033[1;31m[+] Copying the Required files for Magisk/Developement...\n\033[0m"

	fastbootd_function(){

		echo -e "\033[1;32m[i] Do you want to patch your recovery to get Fastbootd..?\n\t1.yes\n\t2.no\n\033[0m"	
		read -p "Choose value (1,2) : " fastbootd_input
		if [ "$fastbootd_input" == 1 ]; then
			recovery_patch
		else 
			echo "Skipping Fastbootd patch.."
		fi
	}

	if [ "$is_legacy" == 1 ] && [ -e system.img ] || [ -e system.img.ext4 ]; then		
		cd "$WDIR/Downloads" #changed dir
		cp boot.img recovery.img "$WDIR/output/"
		cd "$WDIR/output" #changed dir
		tar cvf "$BASE_TAR_NAME" boot.img recovery.img ; rm *.img #cleaning

	elif [ "$PARTITION_SCHEME" == 1 ]; then
			cd "$WDIR/Downloads" #changed dir
			cp boot.img vbmeta.img recovery.img dtbo.img "$WDIR/output/"
			cd "$WDIR/output" #changed dir
			fastbootd_function
			tar cvf "$BASE_TAR_NAME" boot.img vbmeta.img recovery.img dtbo.img; rm *.img #cleaning
		else
			cd "$WDIR/Downloads" #changed dir
			dt_check(){
				if [ -e dt.img ]; then
					is_dt=1
				fi
				if [ -e dtbo.img ]; then
					is_dtbo=1
				fi
			}
			dt_check
			if [ "$is_dt" == 1 ] && [ $is_dtbo == 1 ]; then 
				cp boot.img vbmeta.img recovery.img dtbo.img dt.img "$WDIR/output/"
				cd "$WDIR/output" #changed dir
				fastbootd_function
				tar cvf "$BASE_TAR_NAME" boot.img vbmeta.img recovery.img dtbo.img dt.img; rm *.img #cleaning
			elif [ ! "$is_dt" == 1 ] && [ $is_dtbo == 1 ]; then
				cp boot.img.lz4 vbmeta.img.lz4 recovery.img.lz4 dtbo.img.lz4 "$WDIR/output/"
				cd "$WDIR/output" #changed dir
				fastbootd_function
				tar cvf "$BASE_TAR_NAME" boot.img vbmeta.img recovery.img dtbo.img ; rm *.img #cleaning
			else
			 	cp boot.img vbmeta.img recovery.img "$WDIR/output/"
				cd "$WDIR/output" #changed dir
				fastbootd_function
				tar cvf "$BASE_TAR_NAME" boot.img vbmeta.img recovery.img ; rm *.img #cleaning
			fi

	fi
	zip "${BASE_TAR_NAME}.zip" "$BASE_TAR_NAME"
	rm "$BASE_TAR_NAME"
	echo -e "\n\033[1;32m[i] Zip file created: ${BASE_TAR_NAME}.zip\033[0m"
}

### EXTRACTING SYSTEM PARTITION ####

super_extract(){
	if [ ! "$is_legacy" == 1 ]; then	
		echo -e "\033[1;31m[+] Moving files to super directory...\n\033[0m"
		cd "$WDIR/Downloads"
		CMD
		cd "$WDIR/super" #changed dir
		echo -e "\033[1;32m[i] Cleaned up and you are now in the super directory !\n\033[0m"
		echo -e "\033[1;31m[+] Decompressing ${IMG}...\n\033[0m"
		lz4 "$IMG"
		rm "$IMG"
		echo -e "\n\033[1;32m[i] Decompression completed!\n\033[0m"

		if [ "$PARTITION_SCHEME" == 1 ]; then
			echo -e "\033[1;31m[+] Converting the super image to a RAW image...\n\033[0m"
			chmod +x "$WDIR/Scamsung/bin/simg2img"
			"$WDIR/Scamsung/bin/simg2img" super.img super.img.raw
			rm super.img
			echo -e "\033[1;32m[i] Conversion completed!\n\033[0m"
			echo -e "\033[1;32m[i] Your super partition size is : $(stat -c '%n %s' super.img.raw) bytes\n\033[0m"
			echo -e "\033[1;31m[+] Extracting system, vendor, product, odm partitions from super.img.raw...\n\033[0m"
			chmod +x "$WDIR/Scamsung/bin/lpunpack"
			"$WDIR/Scamsung/bin/lpunpack" super.img.raw && rm super.img.raw
			echo -e "\n\033[1;32m[i]Extraction completed!\033[0m"
		elif [ "$PARTITION_SCHEME" == 2 ]; then
			echo -e "\033[1;32m[i] Your System partition size is : $(stat -c '%n %s' system.img) bytes\n\033[0m"

		fi
	else
		LCMD
	fi
}

repacking(){
	if [ ! "$is_legacy" == 1 ]; then
		echo -e "\033[1;31m[+] Creating System TAR file...\n\033[0m"
		TAR_NAME="System - $DEVICE_NAME.tar"
		if [ "$PARTITION_SCHEME" == 1 ]; then
			tar cf "$TAR_NAME" system.img vendor.img odm.img product.img
		elif [ "$PARTITION_SCHEME" == 2 ]; then
			tar cf "$TAR_NAME" system.img vendor.img product.img
		fi
		echo -e "\nChoose a compression method\n1.ZIP\n2.TAR.XZ (Slower)"
		read -p "Enter value (1,2) : " compression_method
		
		compression_method_input(){
			if [ "$compression_method" == 2 ]; then
				echo -e "\n[i] Compressing objects using XZ compression.."
				xz -9 --threads=0 "$TAR_NAME"
				echo -e "\033[1;32m[i] TAR file created: ${TAR_NAME}.xz\n\033[0m"
				echo -e "\033[1;31m[+] Moving TAR file to Output...\n\033[0m" && mv "${TAR_NAME}.xz" "$WDIR/output"
			elif [ "$compression_method" == 1 ]; then
				echo -e "\n[i] Compressing objects using ZIP compression.."
				zip -r "${TAR_NAME}.zip" "$TAR_NAME"
				echo -e "\033[1;32m[i] ZIP file created: ${TAR_NAME}.zip\n\033[0m"
				echo -e "\033[1;31m[+] Moving TAR file to Output...\n\033[0m" && mv "${TAR_NAME}.zip" "$WDIR/output"
			else
				echo -e "Invalid Input. Try Again..!"
				compression_method_input
			fi
		}
		compression_method_input
		echo -e "\033[1;32m[i] Firmware extraction for device ${DEVICE_NAME} is completed!"
	else
		LCMD
	fi
}

cleanup(){
	cd "$WDIR"
	rm -rf Downloads Workplace super
	echo -e "\033[1;32m\n[i] Cleaned..!\n\033[0m"
	sleep 2
	read -p "Wanna restart the Script ? (1,2) : " confirmation
	if [ "$confirmation" == 1 ]; then	
		restart
	else
		echo "Good bye..!"
		exit 1
	fi
}

no_super(){
	if [ ! "$is_legacy" == 1 ]; then
		echo -e "\033[1;31m[+] Making a Compressed Firmware package without Super/system...\033[0m"
		cd "$WDIR/Downloads"
		rm $IMG
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
				mv "${NON_SUPER}.tar.xz" "$WDIR/output"
			else
				echo "Wrong input..! Try Again..."
				input_no_super
			fi
		}
		input_no_super
		echo -e "\033[1;32m\n[i] Task completed and saved in ${WDIR}/output..!\n[i] Restarting the Script in 5 seconds..!"
		sleep 5
		cleanup
	else
		LCMD
	fi
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
