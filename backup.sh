#!/bin/bash

# This script is totally bullshit. You should use rsnapshot instead.

### This script backups the directories set in the directories array and also backups all MySQL databases if you want it to. ###
### It works with local, USB, NFS and rsync backups. ###
### Tested and working with a Synology NAS. ###

## User variables
declare -A directories=(["webs"]="/var/www" ["sites"]="/etc/apache2/sites-available") # Array with directories to backup (there are some examples).
localDestination="/srv/backups" # Directory where the backups are saved.
data=$(date +%Y%m%d)
dia=$(date +%d)
weekday=$(date +%u)

mysql=1 # Set to 1 to backup mysql databases.

rback=0 # Set to 1 to enable remote backups with plain password or 2 to enable remote backups with keys.
rkey="/home/user/keys/backups.key" # Key for remote login if rback=2.
ruser="backup" # Backup remote user.
rpassword="backuppassword"
rdestination="/volume1/Backups" # Remote backups directory.
remoteserver="192.168.1.100" # Remote server IP address.
fulldestination="${ruser}@${remoteserver}:${rdestination}"

## Backup MySQL function.
function db () {
	directories+=(["databases"]="/var/databases")
	user="backup" # Mysql backup user.
	password="password" # MySQL backup user password.
	savedir="/var/databases"
	if [ ! -d "$savedir" ]
	then
		mkdir -p $savedir
	fi
	databases=$(mysql -u $user -p$password -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)")
	for db in $databases
	do
		mysqldump --force -u $user -p$password $db | gzip > ${savedir}/${db}.sql.gz
	done
}

## Backup files.
function backup () {

	### Daily backup ###
	## Mysql
	files=$(ls /var/databases/*.sql.gz 2> /dev/null | wc -l)
	if [ $files -ne 0 ]
	then
		rm -r /var/databases/*.sql.gz
	fi
	if [ $6 -eq 1 ]
	then
		db # Call function db() to export databases.
	fi
	
	## Files
	declare -a dir=("${!2}")
	for i in ${!dir[@]}
	do
		${SSH} rsync -av --delete ${dir[$i]} ${1}/daily
	done
	
	### Weekly backup ###
	if [ $5 -eq 6 ]
	then
		for i in ${!dir[@]}
		do
			${SSH} "$rpassword" rsync -av --delete ${dir[$i]} ${1}/weekly
		done
	fi
	
	### Monthly backup ###
	if [ $4 -eq 04 ]
	then
		for i in ${!dir[@]}
        do
			${SSH} rsync -avz --delete ${dir[$i]} ${1}/monthly
		done
	fi
}

if [ $rback -eq 0 ]
then
	SSH="" # No ssh command needed.

	## Check if directories exist.
	if [ ! -d "$localDestination/daily" ]
	then
		mkdir -p "$localDestination/daily"
	fi
	if [ ! -d "$localDestination/weekly" ]
	then
		mkdir -p "$localDestination/weekly"
	fi
	if [ ! -d "$localDestination/monthly" ]
	then
		mkdir -p "$localDestination/monthly"
	fi
	
	## Call the function
	backup $localDestination directories[@] $data $dia $weekday $mysql

elif [ $rback -eq 1 ]
then
	SSH="sshpass -p ${rpassword}" # Using sshpass.
	backup $fulldestination directories[@] $data $dia $weekday $mysql # Call the function.

elif [ $rback -eq 2 ]
then
	SSH="ssh -i ${rkey}" # Using ssh key pairs.
	backup $fulldestination directories[@] $data $dia $weekday $mysql # Call the function.
fi
