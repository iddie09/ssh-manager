#!/bin/bash

DB="/etc/ssh-manager/users.db"

green='\033[0;32m'
red='\033[0;31m'
blue='\033[0;34m'
nc='\033[0m'

banner(){

clear

echo -e "${blue}"
echo "======================================="
echo "        ADVANCED SSH MANAGER"
echo "======================================="
echo -e "${nc}"

}

add_user(){

read -p "Username: " user
read -p "Password: " pass
read -p "Quota MB (4000=4GB): " quota
read -p "Expiry days: " days

useradd -M -s /bin/false $user
echo "$user:$pass" | chpasswd

uid=$(id -u $user)

iptables -I OUTPUT -m owner --uid-owner $uid -j ACCEPT
iptables -I INPUT -m owner --uid-owner $uid -j ACCEPT

expire=$(date -d "+$days days" +"%Y-%m-%d")

echo "$user:$uid:$quota:$expire" >> $DB

echo -e "${green}User created successfully${nc}"

sleep 2

}

show_users(){

clear

printf "%-15s %-12s %-12s %-15s\n" "USER" "USED(MB)" "LIMIT" "EXPIRY"

echo "--------------------------------------------------------"

while IFS=: read user uid quota expire
do

bytes=$(iptables -L OUTPUT -v -n -x | grep $uid | awk '{print $2}')

mb=$((bytes/1024/1024))

printf "%-15s %-12s %-12s %-15s\n" "$user" "$mb" "$quota" "$expire"

done < $DB

read -p "Press enter"

}

delete_user(){

read -p "Username to delete: " user

uid=$(id -u $user)

iptables -D OUTPUT -m owner --uid-owner $uid -j ACCEPT
iptables -D INPUT -m owner --uid-owner $uid -j ACCEPT

userdel $user

sed -i "/^$user:/d" $DB

echo "User deleted"

sleep 2

}

while true
do

banner

echo "1  Create SSH User"
echo "2  Show Users"
echo "3  Delete User"
echo "4  Exit"

echo ""

read -p "Select: " opt

case $opt in

1) add_user ;;
2) show_users ;;
3) delete_user ;;
4) exit ;;

esac

done
