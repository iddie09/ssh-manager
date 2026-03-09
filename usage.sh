#!/bin/bash

clear
echo "══════ USER DATA USAGE ══════"
echo ""

printf "%-15s %-10s %-10s %-10s\n" "Username" "Limit" "Used" "Remain"

while read user limit used
do

limit_gb=$(echo "scale=2; $limit/1024" | bc)
used_gb=$(echo "scale=2; $used/1024" | bc)
remain=$(echo "scale=2; $limit_gb-$used_gb" | bc)

printf "%-15s %-10s %-10s %-10s\n" "$user" "${limit_gb}GB" "${used_gb}GB" "${remain}GB"

done < /etc/slowdns-manager/users.db

echo ""
read -p "Press Enter to return"
menu
