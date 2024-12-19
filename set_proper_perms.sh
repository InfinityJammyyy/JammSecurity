#!/bin/bash

echo "Setting proper permissions for user home directories and key system files..."
for user in $(awk -F: '$3 > 999 && $3 < 65534 {print $1}'); do
    [ -d /home/$user ] && sudo chmod -R 750 /home/$user
done
sudo chown root:shadow /etc/shadow
sudo chmod 640 /etc/shadow
sudo chown root:root /etc/passwd
sudo chmod 644 /etc/passwd
sudo chown root:root /etc/sudoers
sudo chmod 440 /etc/sudoers
sudo chown root:root /etc/group
sudo chmod 644 /etc/group
sudo chown -R www-data:www-data /var/www
sudo chmod -R 755 /var/www
