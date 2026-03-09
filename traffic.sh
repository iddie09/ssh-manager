#!/bin/bash

DB="/etc/ssh-manager/users.db"

echo "TOP BANDWIDTH USERS"
echo "--------------------------------"

while IFS=: read user uid quota expire
do

bytes=$(iptables -L OUTPUT -v -n -x | grep $uid | awk '{print $2}')

mb=$((bytes/1024/1024))

echo "$user - $mb MB"

done < $DB | sort -nr -k3
