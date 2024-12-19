#!/bin/bash

echo 'Performing miscellaneous checks and scans...'
output="$HOME/Weirdstuffs.txt"
echo "Enabled Services" | sudo tee "$output"
sudo systemctl list-unit-files --type=service | awk '$2 == "enabled" { print $0 }' | sudo tee -a "$output"
echo "Weird Admins" | sudo tee -a "$output"
awk -F: '$1 == "sudo"' /etc/group | sudo tee -a "$output"
echo "Weird Users (reset their uid)" | sudo tee -a "$output"
awk -F: '$3 > 999 && $3 < 65534 {print $1}' /etc/passwd | sudo tee -a "$output"
echo "Empty passwords" | sudo tee -a "$output"
awk -F: '$2 == ""' /etc/passwd | sudo tee -a "$output"
echo "Non-root uid 0 users" | sudo tee -a "$output"
awk -F: '$3 == 0 && $1 != "root"' /etc/passwd | sudo tee -a "$output"
echo "World writable files" | sudo tee -a "$output"
sudo find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print | sudo tee -a "$output"
echo "No-user files" | sudo tee -a "$output"
sudo find / -xdev \( -nouser -o -nogroup \) -print | sudo tee -a "$output"
