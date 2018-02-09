#!/bin/bash

declare -a keys=("ecdsa" "rsa" "ed25519")
fqdn=$(hostname -f)
host=$(hostname)
f=$host-known_hosts
ip=$(curl -s ipinfo.io/ip)

for key in "${keys[@]}"
do
    printf "$fqdn " >> $f
    sed 's/root.*//' /etc/ssh/ssh_host_${key}_key.pub >> $f
    printf "$ip " >> $f
    sed 's/root.*//' /etc/ssh/ssh_host_${key}_key.pub >> $f
    
done

