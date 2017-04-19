#!/bin/bash

### This script installs a FTP server with TLS in (almost) any Debian-based distro. You must run it as root. ###
### Previously you need a Let's Encrypt cert. ###

if [ "$(id -u)" != "0" ]
then
   echo "This script must be run as root." 1>&2
   exit 1
fi

# Variables and arrays
declare -a Packages=("vsftpd" "openssl")
ftpdomain="" # Domain used in Let's encrypt cert generation.
ftpbanner="" # Banner for the FTP server.
fitxer="# Basic configuration
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
ftpd_banner=$ftpbanner
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list
allow_writeable_chroot=YES
user_config_dir=/etc/vsftpd_user_conf
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd

# Turn on SSL
ssl_enable=YES

# Allow anonymous SSL connections
allow_anon_ssl=NO

# All non-anonymous logins are forced to use a secure SSL connection in order to
# send and receive data on data connections.
force_local_data_ssl=YES

# All non-anonymous logins are forced to use a secure SSL connection in order to send the password.
force_local_logins_ssl=YES

# Permit TLS v1 protocol connections. TLS v1 connections are preferred
ssl_tlsv1=YES

# Permit SSL v2 protocol connections. TLS v1 connections are preferred
ssl_sslv2=NO

# permit SSL v3 protocol connections. TLS v1 connections are preferred
ssl_sslv3=NO

# Disable SSL session reuse (required by WinSCP)
require_ssl_reuse=NO

# Select which SSL ciphers vsftpd will allow for encrypted SSL connections (required by FileZilla)
ssl_ciphers=HIGH

# This option specifies the location of the RSA certificate to use for SSL
# encrypted connections.
rsa_cert_file=/etc/letsencrypt/live/$ftpdomain/fullchain.pem
rsa_private_key_file=/etc/letsencrypt/live/$ftpdomain/privkey.pem"

# Package installation
for i in "${Packages[@]}"
do
    apt-get -y install $i
done

# Backup default config file.
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

# Create files and dirs
mkdir /etc/vsftpd_user_conf
touch /etc/vsftpd.chroot_list

# Config file
echo  "$fitxer" > /etc/vsftpd.conf

# Restart vsftpd
service vsftpd restart

# End
exit 0
