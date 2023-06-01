#!/bin/bash

##Open Sources:
# Monero github https://github.com/moneroexamples/monero-compilation/blob/master/README.md
# Monero Blockchain Explorer https://github.com/moneroexamples/onion-monero-blockchain-explorer
# PiNode-XMR scripts and custom files at my repo https://github.com/shermand100/pinode-xmr
# PiVPN - OpenVPN server setup https://github.com/pivpn/pivpn

#configure languages
sudo apt update && sudo apt install gettext -y
mkdir -p /home/pinodexmr/locale/en/LC_MESSAGES/
# POC around i18n/Localization in a bash script
#(1)
export TEXTDOMAIN=ubuntu-installer.sh
I18NLIB=i18n-lib.sh
#(2)
# source in I18N library - shown above
if [[ -f $I18NLIB ]]
then
        . $I18NLIB
else
        echo "ERROR - $I18NLIB NOT FOUND"
fi

#(3)
## ALLOW USER TO SET LANG PREFERENCE
## assume lang and country code follows
if [[ "$1" = "-lang" ]]
then
        export LC_ALL="$2_$3.UTF-8"
fi

#Welcome
if (whiptail --title "`i18n_display "installerTitle"`" --yesno "`i18n_display "confirmUser"`" 12 60); then

whiptail --title "`i18n_display "installerTitle"`" --msgbox "`i18n_display "beginUserSetup"`" 12 78


##Create new user 'pinodexmr'
sudo adduser pinodexmr --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password

#Set pinodexmr password 'PiNodeXMR'
echo "pinodexmr:PiNodeXMR" | sudo chpasswd
echo -e "\e[32m`i18n_display "passwordChanged"`\e[0m"
sleep 3

##Replace file /etc/sudoers to set global sudo permissions/rules
echo -e "\e[32m`i18n_display "replaceSudoers"`\e[0m"
sleep 3
wget https://raw.githubusercontent.com/monero-ecosystem/PiNode-XMR/ubuntuServer-20.04/etc/sudoers
sudo chmod 0440 ~/sudoers
sudo chown root ~/sudoers
sudo mv ~/sudoers /etc/sudoers
echo -e "\e[32m`i18n_display "success"`\e[0m"
sleep 3

##Change system hostname to PiNodeXMR
echo -e "\e[32m`i18n_display "changeHostname"`\e[0m"
sleep 3
echo 'PiNodeXMR' | sudo tee /etc/hostname
#sudo sed -i '6d' /etc/hosts
echo '127.0.0.1       PiNodeXMR' | sudo tee -a /etc/hosts
sudo hostname PiNodeXMR
echo -e "\e[32m`i18n_display "success"`\e[0m"
sleep 3

##Disable IPv6 (confuses Monero start script if IPv6 is present)
echo -e "\e[32m`i18n_display "disableIpv6"`\e[0m"
sleep 3
echo 'net.ipv6.conf.all.disable_ipv6 = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' | sudo tee -a /etc/sysctl.conf
echo -e "\e[32m`i18n_display "success"`\e[0m"
sleep 3

##Perform system update and upgrade now. This then allows for reboot before next install step, preventing warnings about kernal upgrades when installing the new packages (dependencies).
#setup debug file to track errors
echo -e "\e[32m`i18n_display "createDebug"`\e[0m"
sudo touch /home/pinodexmr/debug.log
sudo chown pinodexmr /home/pinodexmr/debug.log
sudo chmod 777 /home/pinodexmr/debug.log
echo -e "\e[32m`i18n_display "success"`\e[0m"
sleep 3

##Update and Upgrade system
echo -e "\e[32m`i18n_display "updateUpgrade"`\e[0m"
sleep 3
sudo apt-get update 2>&1 | tee -a /home/pinodexmr/debug.log
sudo apt-get --yes -o Dpkg::Options::="--force-confnew" upgrade 2>&1 | tee -a /home/pinodexmr/debug.log
sudo apt-get --yes -o Dpkg::Options::="--force-confnew" dist-upgrade 2>&1 | tee -a /home/pinodexmr/debug.log
sudo apt-get upgrade -y 2>&1 | tee -a /home/pinodexmr/debug.log
echo -e "\e[32m`i18n_display "updateComplete"`\e[0m"
sleep 3

##Auto remove any obsolete packages
sudo apt-get autoremove -y 2>&1 | tee -a /home/pinodexmr/debug.log

#Download stage 2 Install script
echo -e "\e[32m`i18n_display "getInstallerContinue"`\e[0m"
sleep 3
wget https://raw.githubusercontent.com/monero-ecosystem/PiNode-XMR/ubuntuServer-20.04/ubuntu-install-continue.sh
sudo mv ~/ubuntu-install-continue.sh /home/pinodexmr/
sudo chown pinodexmr /home/pinodexmr/ubuntu-install-continue.sh
sudo chmod 755 /home/pinodexmr/ubuntu-install-continue.sh

##make script run when user logs in
echo '. /home/pinodexmr/ubuntu-install-continue.sh' | sudo tee -a /home/pinodexmr/.profile

whiptail --title "`i18n_display "installerTitle"`" --msgbox "`i18n_display "step1Complete"`" 16 60

echo -e "\e[32m****************************************\e[0m"
echo -e "\e[32m****************************************\e[0m"
echo -e "\e[32m**********PiNode-XMR rebooting**********\e[0m"
echo -e "\e[32m**********Reminder:*********************\e[0m"
echo -e "\e[32m**********User: 'pinodexmr'*************\e[0m"
echo -e "\e[32m**********Password: 'PiNodeXMR'*********\e[0m"
echo -e "\e[32m****************************************\e[0m"
echo -e "\e[32m****************************************\e[0m"
sudo reboot

else
exit 0
fi



