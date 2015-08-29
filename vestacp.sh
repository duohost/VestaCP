#!/bin/bash
#
# Minimal requirements
# --------------------
# A 5 dollars a month Digital Ocean Ubuntu 14.04 64bit server ()
# 512 mb ram / 1 CPU
# 20 GB SSD Disk
# 1000 GB Transfer
# Get it at with a 10 dollar rebate at https://www.digitalocean.com/?refcode=4c039b01c48f
#
# After login to your droplet for the first time, copy the line bellow (withouth the first #) and execute it in the terminal
# curl -O https://raw.githubusercontent.com/FastDigitalOceanDroplets/VestaCP/master/vestacp.sh && bash vestacp.sh
#
# When this other process finishes, do the same with the next line in the server
# curl -O https://github.com/FastDigitalOceanDroplets/VestaCP/blob/master/vestacp.sh && bash vestacp.sh


# Prevents doing this from other account than root
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi
##################################
# Interactive Part
# Get admin's email
email=""
valid_email=[[ "$email" =~ "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$" ]]
while [$valid_email]
do
    read -p "Enter admin email: " email
	echo
    if [$valid_email]
    then 
        echo "Email address $email is valid."
    else
        echo "Email address $email is invalid." 
    fi
done

exit

# Creates SWAP on the server
sudo fallocate -l 512M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
sudo sysctl vm.swappiness=10
sudo echo "vm.swappiness=10" >> /etc/sysctl.conf
sudo sysctl vm.vfs_cache_pressure=50
sudo echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

# Change time zone at your new server
dpkg-reconfigure tzdata

# Set the locale on your computer (is not the smartest way, I accept sugestions to do it interactivily)
export LC_ALL=en_US.UTF-8
export LANG="en_US.UTF-8"
export LANGUAGE=en_US.UTF-8
echo 'LC_ALL=en_US.UTF-8' >> /etc/environment
echo 'LANG=en_US.UTF-8' >> /etc/environment
echo 'LANGUAGE=en_US.UTF-8' >> /etc/environment

# Update all your server software
apt-get update
apt-get upgrade
# apt-get dist-upgrade
# apt-get autoremove

# Reconfigure locale
apt-get install --reinstall language-pack-en
locale-gen
locale-gen en_US.UTF-8
dpkg-reconfigure locales

# Change root password for your server
clear
echo "Cambiamos la clave de root"
passwd root
echo

# install vesta with admin's email
curl -O http://vestacp.com/pub/vst-install.sh
bash vst-install.sh -e $email

# De aca para abajo no se ejecuta nada
# Arreglar el MySQL
service mysql stop && service mysql start && dpkg-reconfigure mysql-server-5.5