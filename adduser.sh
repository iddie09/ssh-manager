#!/bin/bash

clear
echo "════════ ADD SSH USER ════════"
echo ""

read -p "Username: " user
read -p "Password: " pass
read -p "Data Limit Number: " limit
read -p "Unit (GB or MB): " unit

useradd -m $user
echo "$user:$pass" | chpasswd

# convert limit to MB
if [[ "$unit" == "GB" || "$unit" == "gb" ]]; then
limit_mb=$((limit*1024))
else
limit_mb=$limit
fi

echo "$user $limit_mb 0" >> /etc/slowdns-manager/users.db

iptables -N $user

iptables -A OUTPUT -m owner --uid-owner $user -j $user
iptables -A INPUT -m owner --uid-owner $user -j $user

iptables -A $user -j RETURN

echo ""
echo "User Created Successfully"
echo "Username : $user"
echo "Limit    : $limit $unit"
echo ""
read -p "Press Enter to return to menu"
menu
