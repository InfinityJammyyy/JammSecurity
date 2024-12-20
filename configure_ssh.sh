#!/bin/bash

# Function to backup a file
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

# Prompt for port input with validation
read -p "Enter the SSH port number (1-65535): " port

# Validate input is a number and within range
while ! [[ $port =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); do
    echo "Invalid port number. Please enter a number between 1 and 65535."
    read -p "Enter the SSH port number (1-65535): " port
done

# Configure SSH with the provided port
echo 'Configuring SSH...'
backup_file /etc/ssh/sshd_config
cat <<EOL | sudo tee /etc/ssh/sshd_config
Port $port
PermitRootLogin no
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM yes
ClientAliveInterval 300
ClientAliveCountMax 0
IgnoreRhosts yes
EOL

echo "SSH has been configured with port $port."
