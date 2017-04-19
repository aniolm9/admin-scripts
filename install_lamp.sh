#!/bin/bash

### This script installs a LAMP server in (almost) any Debian-based distro. You must run it as root. ###

## Notes:
# Installs Apache2, MySQL/MariaDB, PHP and phpMyAdmin.
# Enables the htaccess files.

if [ "$(id -u)" != "0" ]
then
   echo "This script must be run as root." 1>&2
   exit 1
fi

## Variables & arrays
declare -a Packages=("apache2" "apache2.2-common" "apache2-utils" "ssl-cert" "apache2-mpm-prefork" "php5" "libapache2-mod-php5" "php5-common" "mysql-server" "mysql-client" "php5-mysql" "phpmyadmin");
passwordMysql="password"

# MySQL passwords
echo "mysql-server mysql-server/root_password password ${passwordMysql}" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${passwordMysql}" | debconf-set-selections

# Phpmyadmin passwords (same as MySQL).
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${passwordMysql}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${passwordMysql}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${passwordMysql}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

# Package installation
for i in "${Packages[@]}"
do
    apt-get -y install $i
done

# Enable htaccess
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf 

# Apache restart
service apache2 restart

# End
rm $0 ## Deletes himself to avoid having passwords in plain text.
exit 0
