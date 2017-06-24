#!/bin/bash

if [ "$(id -u)" != "0" ]
then
   echo "This script must be run as root." 1>&2
   exit 1
fi

## Variables & arrays
defaultUser=$(id -nu 1000)
sources="/etc/apt/sources.list"
sudoers="/etc/sudoers"
bits=0
declare -a BasicStuff=("build-essential" "checkinstall" "make" "automake" "cmake" "autoconf" "git" "git-core" "rar" "unrar" "p7zip-full" "p7zip-rar" "oracle-java8-installer" "sudo");
declare -a ExtraStuff=(); #Extra programs to be installed.

## Change repositories
cp $sources ${sources}.bak

echo "## Oficials
deb http://ftp.es.debian.org/debian/ jessie main contrib non-free
deb-src http://ftp.es.debian.org/debian/ jessie main contrib non-free

## Actualitzacions
deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main
deb http://ftp.es.debian.org/debian/ jessie-updates main
deb-src http://ftp.es.debian.org/debian/ jessie-updates main

## Backports
deb http://http.debian.net/debian jessie-backports main
deb-src http://http.debian.net/debian jessie-backports main

## Java
deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main
deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" > $sources

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
apt-get update

## Kernel upgrade
bits=$(uname -m)
if [ $bits == "x86_64" ]
then
    echo "Attention! No output will be displayed during the kernel installation."
    sleep 5
    apt-get -t jessie-backports -y install linux-image-amd64 > /dev/null
    apt-get -y install linux-headers-amd64
fi

if [ $bits == "i686" ]
then
    echo "Attention! No output will be displayed during the kernel installation."
    sleep 5
    apt-get -t jessie-backports -y install linux-image-686 > /dev/null
    apt-get -y install linux-headers-686
fi


## Accept Java license
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

## Install packages
for i in "${BasicStuff[@]}"
do
    apt-get -y install $i
done

if [ ${#ExtraStuff[@]} -ne 0 ]; then
    for i in "${ExtraStuff[@]}"
    do
        apt-get -y install $i
    done
fi

## Sudo
echo "${defaultUser} ALL=(ALL:ALL) ALL" >> $sudoers

## Update
echo "alias update='sudo apt update && sudo apt upgrade'" >> /etc/bash.bashrc

## Update
apt-get update
apt-get upgrade -y
apt-get -y autoremove

## End
echo "Everything done! In 10 seconds the system will reboot..."
sleep 10
reboot
