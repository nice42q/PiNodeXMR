#!/bin/bash

##Open Sources:
# Monero github https://github.com/moneroexamples/monero-compilation/blob/master/README.md
# Monero Blockchain Explorer https://github.com/moneroexamples/onion-monero-blockchain-explorer
# PiNode-XMR scripts and custom files at my repo https://github.com/monero-ecosystem/PiNode-XMR
# PiVPN - OpenVPN server setup https://github.com/pivpn/pivpn

###Begin2

#Create debug file for handling install errors:
touch debug.log
echo "
####################
" 2>&1 | tee -a debug.log
echo "Start ubuntu-install-continue.sh script $(date)" 2>&1 | tee -a debug.log
echo "
####################
" 2>&1 | tee -a debug.log

#Establish OS 32 or 64 bit
CPU_ARCH=`getconf LONG_BIT`
echo "OS getconf LONG_BIT $CPU_ARCH" >> debug.log
if [[ $CPU_ARCH -eq 64 ]]
then
  echo "ARCH: 64-bit"
elif [[ $CPU_ARCH -eq 32 ]]
then
  echo "ARCH: 32-bit"
else
  echo "OS Unknown"
fi
sleep 3

whiptail --title "PiNode-XMR Continue Ubuntu LTS Installer" --msgbox "Your PiNode-XMR is taking shape...\n\nThis next part will take several hours dependant on your hardware but I won't require any further input from you. I can be left to install myself if you wish\n\nSelect ok to continue setup" 16 60
###Continue as 'pinodexmr'

##Configure temporary Swap file if needed (swap created is not persistant and only for compiling monero. It will unmount on reboot)
if (whiptail --title "PiNode-XMR Ubuntu Installer" --yesno "For Monero to compile successfully 2GB of RAM is required.\n\nIf your device does not have 2GB RAM it can be artificially created with a swap file\n\nDo you have 2GB RAM on this device?\n\n* YES\n* NO - I do not have 2GB RAM (create a swap file)" 18 60); then
	echo -e "\e[32mSwap file unchanged\e[0m"
	sleep 3
		else
			sudo fallocate -l 2G /swapfile 2>&1 | tee -a debug.log
			sudo chmod 600 /swapfile 2>&1 | tee -a debug.log
			sudo mkswap /swapfile 2>&1 | tee -a debug.log
			sudo swapon /swapfile 2>&1 | tee -a debug.log
			echo -e "\e[32mSwap file of 2GB Configured and enabled\e[0m"
			free -h
			sleep 3
fi

###Continue as 'pinodexmr'
cd
echo -e "\e[32mLock old user 'pi'\e[0m"
sleep 2
sudo passwd --lock pi
echo -e "\e[32mUser 'pi' Locked\e[0m"
sleep 3
echo -e "\e[32mLock old user 'ubuntu'\e[0m"
sleep 2
sudo passwd --lock ubuntu
echo -e "\e[32mUser 'ubuntu' Locked\e[0m"
sleep 3

##Update and Upgrade system
echo -e "\e[32mReceiving and applying Ubuntu updates to latest versions\e[0m"
sleep 3
sudo apt update 2>&1 | tee -a debug.log && sudo apt upgrade -y 2>&1 | tee -a debug.log
##Auto remove any obsolete packages
sudo apt autoremove -y 2>&1 | tee -a debug.log

##Installing dependencies for --- Web Interface
	echo "Installing dependencies for --- Web Interface" 2>&1 | tee -a debug.log
echo -e "\e[32mInstalling dependencies for --- Web Interface\e[0m"
sleep 3
sudo apt install apache2 shellinabox php php-common avahi-daemon -y 2>&1 | tee -a debug.log
sleep 3

##Installing dependencies for --- Monero
	echo "Installing dependencies for --- Monero" 2>&1 | tee -a debug.log
echo -e "\e[32mInstalling dependencies for --- Monero\e[0m"
sleep 3
sudo apt update && sudo apt install build-essential cmake pkg-config libssl-dev libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev libpgm-dev qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev ccache doxygen graphviz -y 2>&1 | tee -a debug.log
sleep 2
	echo "manual build of gtest for --- Monero" 2>&1 | tee -a debug.log
sudo apt-get install libgtest-dev 2>&1 | tee -a debug.log && cd /usr/src/gtest 2>&1 | tee -a debug.log && sudo cmake . 2>&1 | tee -a debug.log && sudo make 2>&1 | tee -a debug.log
sudo mv lib/libg* /usr/lib/ 2>&1 | tee -a debug.log

##Checking all dependencies are installed for --- miscellaneous (security tools-fail2ban-ufw, menu tool-dialog, screen, mariadb)
	echo "Installing dependencies for --- miscellaneous" 2>&1 | tee -a debug.log
echo -e "\e[32mChecking all dependencies are installed for --- Miscellaneous\e[0m"
sleep 3
sudo apt install git mariadb-client mariadb-server screen exfat-fuse exfat-utils fail2ban ufw dialog jq libcurl4-openssl-dev libpthread-stubs0-dev -y 2>&1 | tee -a debug.log
#libcurl4-openssl-dev & libpthread-stubs0-dev for block-explorer
sleep 3

##Clone PiNode-XMR to device from git
	echo "Clone PiNode-XMR to device from git" 2>&1 | tee -a debug.log
echo -e "\e[32mDownloading PiNode-XMR files\e[0m"
sleep 3
git clone -b ubuntuServer-20.04 --single-branch https://github.com/monero-ecosystem/PiNode-XMR.git 2>&1 | tee -a debug.log


##Configure ssh security. Allows only user 'pinodexmr'. Also 'root' login disabled via ssh, restarts config to make changes
	echo "Configure ssh security" 2>&1 | tee -a debug.log
echo -e "\e[32mConfiguring SSH security\e[0m"
sleep 3
sudo mv /home/pinodexmr/PiNode-XMR/etc/ssh/sshd_config /etc/ssh/sshd_config 2>&1 | tee -a debug.log
sudo chmod 644 /etc/ssh/sshd_config 2>&1 | tee -a debug.log
sudo chown root /etc/ssh/sshd_config 2>&1 | tee -a debug.log
sudo /etc/init.d/ssh restart 2>&1 | tee -a debug.log
echo -e "\e[32mSSH security config complete\e[0m"
sleep 3


##Enable PiNode-XMR on boot
	echo "Enable PiNode-XMR on boot" 2>&1 | tee -a debug.log
echo -e "\e[32mEnable PiNode-XMR on boot\e[0m"
sleep 3
sudo mv /home/pinodexmr/PiNode-XMR/etc/rc.local /etc/rc.local 2>&1 | tee -a debug.log
sudo chmod 755 /etc/rc.local 2>&1 | tee -a debug.log
sudo chown root /etc/rc.local 2>&1 | tee -a debug.log
echo -e "\e[32mSuccess\e[0m"
sleep 3

##Add PiNode-XMR systemd services
	echo "Add PiNode-XMR systemd services" 2>&1 | tee -a debug.log
echo -e "\e[32mAdd PiNode-XMR systemd services\e[0m"
sleep 3
sudo mv /home/pinodexmr/PiNode-XMR/etc/systemd/system/*.service /etc/systemd/system/ 2>&1 | tee -a debug.log
sudo chmod 644 /etc/systemd/system/*.service 2>&1 | tee -a debug.log
sudo chown root /etc/systemd/system/*.service 2>&1 | tee -a debug.log
sudo systemctl daemon-reload 2>&1 | tee -a debug.log
sudo systemctl start statusOutputs.service 2>&1 | tee -a debug.log
sudo systemctl enable statusOutputs.service 2>&1 | tee -a debug.log
echo -e "\e[32mSuccess\e[0m"
sleep 3

#Configure apache server for access to monero log file
	sudo mv /home/pinodexmr/PiNode-XMR/etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf 2>&1 | tee -a debug.log
sudo chmod 777 /etc/apache2/sites-enabled/000-default.conf 2>&1 | tee -a debug.log
sudo chown root /etc/apache2/sites-enabled/000-default.conf 2>&1 | tee -a debug.log
sudo /etc/init.d/apache2 restart 2>&1 | tee -a debug.log

echo -e "\e[32mSuccess\e[0m"
sleep 3

##Setup local hostname
	echo "Setup local hostname" 2>&1 | tee -a debug.log
sudo mv /home/pinodexmr/PiNode-XMR/etc/avahi/avahi-daemon.conf /etc/avahi/avahi-daemon.conf 2>&1 | tee -a debug.log
sudo /etc/init.d/avahi-daemon restart 2>&1 | tee -a debug.log

##Copy PiNode-XMR scripts to home folder
echo -e "\e[32mMoving PiNode-XMR scripts into position\e[0m"
sleep 3
mv /home/pinodexmr/PiNode-XMR/home/pinodexmr/* /home/pinodexmr/ 2>&1 | tee -a debug.log
mv /home/pinodexmr/PiNode-XMR/home/pinodexmr/.profile /home/pinodexmr/ 2>&1 | tee -a debug.log
sudo chmod 777 -R /home/pinodexmr/* 2>&1 | tee -a debug.log #Read/write access needed by www-data to action php port, address customisation
echo -e "\e[32mSuccess\e[0m"
sleep 3

##Configure Web-UI
	echo "Configure Web-UI" 2>&1 | tee -a debug.log
echo -e "\e[32mConfiguring Web-UI\e[0m"
sleep 3
#First move hidden file specifically .htaccess file then entire directory
sudo mv /home/pinodexmr/PiNode-XMR/HTML/.htaccess /var/www/html/ 2>&1 | tee -a debug.log
sudo mv /home/pinodexmr/PiNode-XMR/HTML/*.* /var/www/html/ 2>&1 | tee -a debug.log
sudo mv /home/pinodexmr/PiNode-XMR/HTML/images /var/www/html 2>&1 | tee -a debug.log
sudo chown www-data -R /var/www/html/ 2>&1 | tee -a debug.log
sudo chmod 777 -R /var/www/html/ 2>&1 | tee -a debug.log


# ********************************************
# ******START OF MONERO SOURCE BULD******
# ********************************************
##Build Monero and Onion Blockchain Explorer (the simple but time comsuming bit)
	echo "Build Monero" 2>&1 | tee -a debug.log
#First build monero, single build directory

	#Download latest Monero release/tag number
wget -q https://raw.githubusercontent.com/monero-ecosystem/PiNode-XMR/master/moneroLatestTag.sh -O /home/pinodexmr/moneroLatestTag.sh 2>&1 | tee -a debug.log
chmod 755 /home/pinodexmr/moneroLatestTag.sh 2>&1 | tee -a debug.log
. /home/pinodexmr/moneroLatestTag.sh 2>&1 | tee -a debug.log

echo -e "\e[32mDownloading Monero $TAG\e[0m"
sleep 3
#git clone --recursive https://github.com/monero-project/monero.git       #Dev Branch
git clone --recursive https://github.com/monero-project/monero.git 2>&1 | tee -a debug.log #Latest Stable Branch
echo -e "\e[32mBuilding Monero $TAG\e[0m"
echo -e "\e[32m****************************************************\e[0m"
echo -e "\e[32m****************************************************\e[0m"
echo -e "\e[32m***This will take a 3-8hours - Hardware Dependent***\e[0m"
echo -e "\e[32m****************************************************\e[0m"
echo -e "\e[32m****************************************************\e[0m"
sleep 10
cd monero
git checkout $TAG 2>&1 | tee -a debug.log
git submodule sync 2>&1 | tee -a debug.log && git submodule update --init --force 2>&1 | tee -a debug.log
USE_SINGLE_BUILDDIR=1 make release 2>&1 | tee -a debug.log
cd
#Make dir .bitmonero to hold lmdb. Needs to be added before drive mounted to give mount point. Waiting for monerod to start fails mount.
mkdir .bitmonero 2>&1 | tee -a debug.log

echo -e "\e[32mBuilding Monero Blockchain Explorer[0m"
echo -e "\e[32m*******************************************************\e[0m"
echo -e "\e[32m***This will take a few minutes - Hardware Dependent***\e[0m"
echo -e "\e[32m*******************************************************\e[0m"
sleep 10
		echo "Build Monero Onion Block Explorer" 2>&1 | tee -a debug.log
git clone https://github.com/moneroexamples/onion-monero-blockchain-explorer.git 2>&1 | tee -a debug.log
cd onion-monero-blockchain-explorer
mkdir build
cd build
cmake .. 2>&1 | tee -a debug.log
make 2>&1 | tee -a debug.log
cd
# ********************************************
# ********END OF MONERO SOURCE BULD **********
# ********************************************

# #********************************************
# #*******START OF TEMP BINARY USE*******
# #**************(Disabled)********************

# #Define Install Monero function to reduce repeat script
# function f_installMonero {
# echo "Downloading pre-built Monero from get.monero" 2>&1 | tee -a debug.log
# #Make standard location for Monero
# mkdir -p ~/monero/build/release/bin
# if [[ $CPU_ARCH -eq 64 ]]
# then
#   #Download 64-bit Monero
# wget https://downloads.getmonero.org/cli/linuxarm8
# #Make temp folder to extract binaries
# mkdir temp && tar -xvf linuxarm8 -C ~/temp
# #Move Monerod files to standard location
# mv /home/pinodexmr/temp/monero-aarch64-linux-gnu-v0.17.3.0/monero* /home/pinodexmr/monero/build/release/bin/
# rm linuxarm8
# else
#   #Download 32-bit Monero
# wget https://downloads.getmonero.org/cli/linuxarm7
# #Make temp folder to extract binaries
# mkdir temp && tar -xvf linuxarm7 -C ~/temp
# #Move Monerod files to standard location
# mv /home/pinodexmr/temp/monero-arm-linux-gnueabihf-v0.17.3.0/monero* /home/pinodexmr/monero/build/release/bin/
# rm linuxarm7
# fi
# #Make dir .bitmonero to hold lmdb. Needs to be added before drive mounted to give mount point. Waiting for monerod to start fails mount.
# mkdir .bitmonero 2>&1 | tee -a debug.log
# #Clean-up used downloaded files
# rm -R ~/temp
# }


# if [[ $CPU_ARCH -ne 64 ]] && [[ $CPU_ARCH -ne 32 ]]
# then
#   if (whiptail --title "OS version" --yesno "I've tried to auto-detect what version of Monero you need based on your OS but I've not been successful.\n\nPlease select your OS architecture..." 8 78 --no-button "32-bit" --yes-button "64-bit"); then
#     CPU_ARCH=64
# 	f_installMonero
# 	else
#     CPU_ARCH=32
# 	f_installMonero
#   fi
# else
#  f_installMonero
# fi

# #********************************************
# #*******END OF TEMP BINARY USE*******
# #**************(Disabled)********************

##Install crontab
		echo "Install crontab" 2>&1 | tee -a debug.log
echo -e "\e[32mSetup crontab\e[0m"
sleep 3
sudo crontab /home/pinodexmr/PiNode-XMR/var/spool/cron/crontabs/root 2>&1 | tee -a debug.log
crontab /home/pinodexmr/PiNode-XMR/var/spool/cron/crontabs/pinodexmr 2>&1 | tee -a debug.log
echo -e "\e[32mSuccess\e[0m"
sleep 3

##Set Swappiness lower
		echo "Set RAM Swappiness lower" 2>&1 | tee -a debug.log
sudo sysctl vm.swappiness=10 2>&1 | tee -a debug.log

## Remove left over files from git clone actions
	echo "Remove left over files from git clone actions" 2>&1 | tee -a debug.log
echo -e "\e[32mCleanup leftover directories\e[0m"
sleep 3
sudo rm -r /home/pinodexmr/PiNode-XMR/ 2>&1 | tee -a debug.log
sudo rm /home/pinodexmr/moneroLatestTag.sh 2>&1 | tee -a debug.log

##Change log in menu to 'main'
#Delete line 28 (previous setting)
wget -O ~/.profile https://raw.githubusercontent.com/monero-ecosystem/PiNode-XMR/ubuntuServer-20.04/home/pinodexmr/.profile 2>&1 | tee -a debug.log

##End debug log
echo "
####################
" 2>&1 | tee -a debug.log
echo "End raspbian-pinodexmr.sh script $(date)" 2>&1 | tee -a debug.log
echo "
####################
" 2>&1 | tee -a debug.log

## Install complete
echo -e "\e[32mAll Installs complete\e[0m"
whiptail --title "PiNode-XMR Continue Install" --msgbox "Your PiNode-XMR is ready\n\nInstall complete. When you log in after the reboot use the menu to change your passwords and other features.\n\nEnjoy your Private Node\n\nSelect ok to reboot" 16 60
echo -e "\e[32m****************************************\e[0m"
echo -e "\e[32m****************************************\e[0m"
echo -e "\e[32m**********PiNode-XMR rebooting**********\e[0m"
echo -e "\e[32m**********Reminder:*********************\e[0m"
echo -e "\e[32m**********User: 'pinodexmr'*************\e[0m"
echo -e "\e[32m**********Password: 'PiNodeXMR**********\e[0m"
echo -e "\e[32m****************************************\e[0m"
echo -e "\e[32m****************************************\e[0m"
sleep 10
sudo reboot
