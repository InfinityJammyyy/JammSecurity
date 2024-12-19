#!/bin/bash

backup_file() {
    local file=$1
    if [[ -f $file ]]; then
        local backup="${file}.bak"
        local count=1
        while [[ -f $backup ]]; do
            backup="${file}.bak${count}"
            ((count++))
        done
        sudo cp "$file" "$backup"
    fi
}

echo 'Configuring PAM pwquality...'

backup_file /etc/security/pwquality.conf
sudo tee /etc/security/pwquality.conf > /dev/null <<EOL
minlen = 12
minclass = 3
maxrepeat = 3
maxsequence = 3
reject_username = true
EOL

backup_file /etc/pam.d/common-password
sudo sed -i '/pam_pwquality.so/d' /etc/pam.d/common-password
if ! sudo grep -q 'pam_pwquality.so' /etc/pam.d/common-password; then
    echo 'password requisite pam_pwquality.so retry=3 enforce_for_root' | sudo tee -a /etc/pam.d/common-password > /dev/null
fi
