#!/bin/bash

## Run this as non-root script ###
if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script as root (sudo)"
    exit 1
fi

sudo -v || { echo "Sudo privileges required."; exit 1; }

sudo apt update -y && sudo apt upgrade -y && sudo apt install -y dialog mawk

# Function to create a backup of a file
backup_file() {
    local file=$1
    if [[ -f $file ]]; then
        local backup="$file.bak"
        local count=1
        while [[ -f $backup ]]; do
            backup="$file.bak$count"
            ((count++))
        done
        sudo cp "$file" "$backup"
    fi
}

# Function to install individual packages
install_packages() {
    while true; do
        cmd=(dialog --backtitle "Jamm Security" --title "Package Installer" \
            --separate-output --ok-label "Install" --cancel-label "Quit" \
            --checklist "Select the packages to install:" 20 70 10)

        options=(
            1 "Install lynis" off
            2 "Install clamav" off
            3 "Install ufw" off
            4 "Install fail2ban" off
            5 "Install pam-pwquality" off
            6 "Install auditd" off
            7 "Install chkrootkit" off
            8 "Install rkhunter" off
        )

        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        if [[ $? -ne 0 ]]; then
            echo "Exiting installer."
            exit 0
        fi

        clear

        for choice in $choices; do
            case $choice in
                1) sudo apt install -y lynis ;;
                2) sudo apt install -y clamav ;;
                3) sudo apt install -y ufw ;;
                4) sudo apt install -y fail2ban ;;
                5) sudo apt install -y libpam-pwquality ;;
                6) sudo apt install -y auditd ;;
                7) sudo apt install -y chkrootkit ;;
                8) sudo apt install -y rkhunter ;;
            esac
        done

        break
    done
}

install_packages

# Functions to handle each security task
run_auditing() {
    echo 'Setting up auditing...'
    sudo auditctl -e 1
}

configure_pam_pwquality() {
    echo 'Configuring PAM pwquality...'
    backup_file /etc/security/pwquality.conf

    cat <<EOL | sudo tee /etc/security/pwquality.conf
minlen = 12
minclass = 3
maxrepeat = 3
maxsequence = 3
reject_username = true
EOL

    backup_file /etc/pam.d/common-password
    sudo sed -i '/pam_pwquality.so/d' /etc/pam.d/common-password
    echo 'password requisite pam_pwquality.so retry=3' | sudo tee -a /etc/pam.d/common-password
}

configure_firewall() {
    echo 'Setting up firewall...'
    sudo ufw enable
    sudo ufw allow 443
}

configure_ssh() {
    echo 'Configuring SSH...'
    backup_file /etc/ssh/sshd_config
    cat <<EOL | sudo tee /etc/ssh/sshd_config
Port 443
PermitRootLogin no
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM yes
ClientAliveInterval 300
ClientAliveCountMax 0
IgnoreRhosts yes
EOL
    sudo sshd -t
}

manage_passwords() {
    echo 'Managing user passwords...'
    sudo passwd -l root
    backup_file /etc/login.defs
    sudo sed -i 's/PASS_MAX_DAYS.*$/PASS_MAX_DAYS 90/;s/PASS_MIN_DAYS.*$/PASS_MIN_DAYS 10/;s/PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs
    backup_file /etc/pam.d/common-auth
    echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' | sudo tee -a /etc/pam.d/common-auth
}

misc_checks() {
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
}

rootkit_check() {
    echo 'Checking for rootkits...'
    output="$HOME/Rootkit.txt"
    sudo chkrootkit | sudo tee "$output"
    sudo rkhunter --update | sudo tee -a "$output"
    sudo rkhunter --check | sudo tee -a "$output"
}

run_lynis() {
    echo 'Running Lynis security audit...'
    output="$HOME/LYNIS.txt"
    sudo lynis audit system | sudo tee "$output"
}

run_clamav() {
    echo 'Running ClamAV scan...'
    output="$HOME/ClamAV_Report.txt"
    sudo freshclam
    sudo clamscan --infected --remove --recursive / | sudo tee "$output"
}

set_proper_perms() {
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
}

configure_lightdm() {
    echo 'Configuring LightDM...'
    backup_file /etc/lightdm/lightdm.conf
    cat <<EOL | sudo tee /etc/lightdm/lightdm.conf
allow-guest=false
greeter-hide-users=true
greeter-show-manual-login=true
autologin-user=none
EOL
}

# Main dialog interface
while true; do
    cmd=(dialog --backtitle "Jamm Security" --title "Security Configuration Script" \
        --separate-output --ok-label "Run Tasks" --cancel-label "Quit" \
        --checklist "Select the tasks to execute:" 20 70 10)

    options=(
        1 "Add Auditing" off
        2 "Configure PAM pwquality" off
        3 "Configure Firewall" off
        4 "Configure SSH" off
        5 "Manage Passwords" off
        6 "Miscellaneous Checks and Scans" off
        7 "Rootkit Check" off
        8 "Run Lynis Security Audit" off
        9 "Run ClamAV Scan" off
        10 "Set Proper Permissions" off
        11 "Configure LightDM" off
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    if [[ $? -ne 0 ]]; then
        echo "Exiting script."
        exit 0
    fi

    clear

    for choice in $choices; do
        case $choice in
            1) run_auditing ;;
            2) configure_pam_pwquality ;;
            3) configure_firewall ;;
            4) configure_ssh ;;
            5) manage_passwords ;;
            6) misc_checks ;;
            7) rootkit_check ;;
            8) run_lynis ;;
            9) run_clamav ;;
            10) set_proper_perms ;;
            11) configure_lightdm ;;
        esac
    done

    break

done

echo "All selected tasks completed. Exiting script."
exit 0
