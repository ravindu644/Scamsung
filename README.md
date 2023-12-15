# Samsung Firmware Extractor 3.0 - (aka Scamsung)

A simple way to root your Samsung device without wasting data and time... ❤️ <br>

<img src="https://github.com/ravindu644/Scamsung/assets/126038496/17cf89f4-5304-4991-b711-448be2be34e2" width=75% align="center"> 

## Quick Links 😌

01. [Features](https://github.com/ravindu644/Scamsung?tab=readme-ov-file#---features-%EF%B8%8F---)
02. [How to run](https://github.com/ravindu644/Scamsung?tab=readme-ov-file#how-to-run-%EF%B8%8F)
03. [How to run the script on a VPS or locally (if you are rich 🗿)](https://github.com/ravindu644/Scamsung?tab=readme-ov-file#how-to-run-the-script-on-a-vps-or-locally-if-you-are-rich-)
04. [How to root your Samsung device with the help of my Script? [NO TWRP!]](https://github.com/ravindu644/Scamsung/wiki/How-to-root-your-Samsung-device-with-help-of-my-Script%3F-%5B-NO-TWRP-!-%5D) 😉 <hr>

## <i> - Features ⚡️ - </i>

#### ✅ 01. Extracting only the required files for Magisk root > Saving in your GDrive.
- No need to download the whole firmware package, just get files around 100MB.
#### ✅ 02. Patch the stock recovery image to get fastbootd back...! (Might not work on every device)
- Based on - [Patch-Recovery](https://github.com/Johx22/Patch-Recovery)
#### ✅ 03. Downloading the images inside the AP and CSC without super/system images.
#### ✅ 04. Unpacking the system, vendor, product, and odm images from super.img and Compressing the firmware package using extreme xz compression.

## More features are coming soon... <hr>

## How to run...? 🏃‍♂️

#### 01. Open the Script in Google Colab: [![Colab for images](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/ravindu644/Scamsung/blob/Samsung/Scamsung.ipynb)
#### 02. Press all the play buttons (▶️).
#### 03. The script will ask you a firmware link. You must put a direct link for the full firmware package. I prefer samfw.com for this.
- Open samfw.com.
- Type your model number > choose your current region (CSC).
- Go to your phone's settings > about phone > software information > find the last digits of your build number.
  <img src="https://github.com/ravindu644/Scamsung/assets/126038496/c2b26615-bfcb-4e5a-b207-96b84b7f17d5" width=55%>
- Find the exact firmware version that matches your build number.
- Click "Download on Samfw server" > once the download started, cancel it and go to the download page by pressing "ctrl + j".
- Right-click on the canceled firmware file and choose "copy link"
- Then give the link to the script.  
#### 04. Once my script downloaded the firmware of your device, it will ask for "What you want to do...?" like this:
<img src="https://github.com/ravindu644/Scamsung/assets/126038496/cd54a4a7-e041-4a47-af47-912b200c2fa7" width=75% align="center"> 

#### 05. If you want to dump only the files for root, just press 1, and the script will do the task for you.
- Jump to the wiki to know how to use my script to root your device.

## How to run the script on a VPS or locally (if you are rich 🗿)

### Paste this in the terminal > Press enter :

```
export setup_dir=$(pwd); curl -LSs https://raw.githubusercontent.com/ravindu644/Scamsung/Samsung/setup.sh | bash && bash "${setup_dir}/Scamsung/scamsung.sh"
```

### Yet another project by [@Ravindu_Deshan](https://t.me/Ravindu_Deshan) for [@SamsungTweaks](https://t.me/SamsungTweaks) ❤️
#### Made with ❤️ in Sri Lanka 🇱🇰
