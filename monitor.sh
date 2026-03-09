#!/bin/bash

DB="/etc/ssh-manager/users.db"

while true
do

while IFS=: read user uid quota expire
do

bytes=$(iptables -L OUTPUT -v -n -x | grep $uid | awk '{print $2}')

mb=$((bytes/1024/1024))

today=$(date +"%Y-%m-%d")

if [ "$mb" -ge "$quota" ] || [[ "$today" > "$expire" ]]
then

pkill -u $user

iptables -D OUTPUT -m owner --uid-owner $uid -j ACCEPT
iptables -D INPUT -m owner --uid-owner $uid -j ACCEPT

userdel $user

sed -i "/^$user:/d" $DB

fi

done < $DB

sleep 5

done
