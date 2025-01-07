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

        if sudo cp "$file" "$backup"; then
            echo "Backup of $file created as $backup."
        else
            echo "Failed to create a backup of $file." >&2
            exit 1
        fi
    else
        echo "File $file does not exist; no backup created." >&2
    fi
}

echo 'Configuring PAM pwquality...'

backup_file /etc/security/pwquality.conf
if sudo tee /etc/security/pwquality.conf > /dev/null <<EOL
minlen = 12
minclass = 3
maxrepeat = 3
maxsequence = 3
reject_username = true
EOL
then
    echo "Updated /etc/security/pwquality.conf successfully."
else
    echo "Failed to update /etc/security/pwquality.conf." >&2
    exit 1
fi

backup_file /etc/pam.d/common-password

if sudo sed -i '/pam_pwquality\.so/d' /etc/pam.d/common-password; then
    echo "Removed existing pam_pwquality.so entries from /etc/pam.d/common-password."
else
    echo "Failed to modify /etc/pam.d/common-password." >&2
    exit 1
fi

if ! sudo grep -q 'pam_pwquality\.so' /etc/pam.d/common-password; then
    if echo 'password requisite pam_pwquality.so retry=3 enforce_for_root' | sudo tee -a /etc/pam.d/common-password > /dev/null; then
        echo "Added pam_pwquality.so configuration to /etc/pam.d/common-password."
    else
        echo "Failed to add pam_pwquality.so configuration to /etc/pam.d/common-password." >&2
        exit 1
    fi
else
    echo "pam_pwquality.so configuration already exists in /etc/pam.d/common-password."
fi

echo "PAM pwquality configuration completed successfully."
