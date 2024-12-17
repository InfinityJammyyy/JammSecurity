#!/bin/bash

## Run this as root script ###

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root (sudo)"
    exit 1
fi

## Run this as root script ###

sudo apt update -y && sudo apt upgrade -y && sudo apt install -y dialog  mawk

# Function to install individual packages
install_packages() {
    while true; do
        cmd=(dialog --backtitle "Package Installer" \
            --separate-output \
            --checklist "Select the packages to install:" 20 70 10)

        options=(
            1 "Install lynis" off
            2 "Install clamav" off
            3 "Install ufw" off
            4 "Install fail2ban" off
            5 "Install libpam-cracklib" off
            6 "Install auditd" off
            7 "Install chkrootkit" off
            8 "Install rkhunter" off
            9 "Quit" off
        )

        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        clear

        for choice in $choices; do
            case $choice in
                1) sudo apt install -y lynis ;;
                2) sudo apt install -y clamav ;;
                3) sudo apt install -y ufw ;;
                4) sudo apt install -y fail2ban ;;
                5) sudo apt install -y libpam-cracklib ;;
                6) sudo apt install -y auditd ;;
                7) sudo apt install -y chkrootkit ;;
                8) sudo apt install -y rkhunter ;;
                9) echo "Exiting installer."; return ;;
            esac
        done
    done
}

install_packages

# Functions to handle each security task
run_auditing() {
    echo 'Setting up auditing...'
    auditctl -e 1
}

configure_pam() {
    echo 'Configuring PAM...'
    echo "minlen=12" >> /etc/security/pwquality.conf
    echo "dcredit=-1" >> /etc/security/pwquality.conf
    echo "ucredit=-1" >> /etc/security/pwquality.conf
    echo "ocredit=-1" >> /etc/security/pwquality.conf
    echo "lcredit=-1" >> /etc/security/pwquality.conf
}

configure_firewall() {
    echo 'Setting up firewall...'
    sudo ufw enable
    sudo ufw allow 443
}

configure_ssh() {
    echo 'Configuring SSH...'
    sudo rm -rf '/etc/ssh/sshd_config'
    sudo touch '/etc/ssh/sshd_config'
    sudo echo "Port 443" | sudo tee -a /etc/ssh/sshd_config
    sudo echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config
    sudo echo "ChallengeResponseAuthentication no" | sudo tee -a /etc/ssh/sshd_config
    sudo echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
    sudo echo "UsePAM yes" | sudo tee -a /etc/ssh/sshd_config
    sudo echo "ClientAliveInterval 300" | sudo tee -a /etc/ssh/sshd_config
    sudo echo "ClientAliveCountMax 0" | sudo tee -a /etc/ssh/sshd_config
    sudo echo "IgnoreRhosts yes" | sudo tee -a /etc/ssh/sshd_config
    sudo sshd -t
}

manage_passwords() {
    echo 'Managing user passwords...'
    sudo passwd -l root
    sed -i 's/PASS_MAX_DAYS.*$/PASS_MAX_DAYS 90/;s/PASS_MIN_DAYS.*$/PASS_MIN_DAYS 10/;s/PASS_WARN_AGE.*$/PASS_WARN_AGE 7/' /etc/login.defs
    echo 'auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' >> /etc/pam.d/common-auth
    sed -i 's/\(pam_unix\.so.*\)$/\1 remember=5 minlen=8/' /etc/pam.d/common-password
    sed -i 's/\(pam_cracklib\.so.*\)$/\1 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
}

misc_checks() {
    echo 'Performing miscellaneous checks and scans...'
    touch ~/Weirdstuffs.txt
    echo "Weird Admins" >> ~/Weirdstuffs.txt
    mawk -F: '$1 == "sudo"' /etc/group >> ~/Weirdstuffs.txt
    echo "Weird Users (reset their uid)" >> ~/Weirdstuffs.txt
    mawk -F: '$3 > 999 && $3 < 65534 {print $1}' /etc/passwd >> ~/Weirdstuffs.txt
    echo "Empty passwords" >> ~/Weirdstuffs.txt
    mawk -F: '$2 == ""' /etc/passwd >> ~/Weirdstuffs.txt
    echo "Non-root uid 0 users" >> ~/Weirdstuffs.txt
    mawk -F: '$3 == 0 && $1 != "root"' /etc/passwd >> ~/Weirdstuffs.txt
    echo "Illegal materials" >> ~/Weirdstuffs.txt
    find /home/ -type f \( -name "*.mp3" -o -name "*.mp4" \) >> ~/Weirdstuffs.txt
    echo "Hacking stuffs" >> ~/Weirdstuffs.txt
    find /home/ -type f \( -name "*.tar.gz" -o -name "*.tgz" -o -name "*.zip" -o -name "*.deb" \) >> ~/Weirdstuffs.txt
    echo "World writable files" >> ~/Weirdstuffs.txt
    find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print >> ~/Weirdstuffs.txt
    echo "No-user files" >> ~/Weirdstuffs.txt
    find / -xdev \( -nouser -o -nogroup \) -print >> ~/Weirdstuffs.txt
}

rootkit_check() {
    echo 'Checking for rootkits...'
    sudo chkrootkit | tee ~/Rootkit.txt
    sudo rkhunter --update | tee ~/Rootkit.txt
    sudo rkhunter --check | tee ~/Rootkit.txt
}

run_lynis() {
    echo 'Running Lynis security audit...'
    sudo lynis audit system | tee ~/LYNIS.txt
}

run_clamav() {
    echo 'Running ClamAV scan...'
    sudo freshclam
    sudo clamscan --infected --remove --recursive /
}

# Main dialog interface
while true; do
    cmd=(dialog --backtitle "Security Configuration Script" \
        --separate-output \
        --checklist "Select the tasks to execute:" 20 70 10)

    options=(
        1 "Add Auditing" off
        2 "Configure PAM" off
        3 "Configure Firewall" off
        4 "Configure SSH" off
        5 "Manage Passwords" off
        6 "Miscellaneous Checks and Scans" off
        7 "Rootkit Check" off
        8 "Run Lynis Security Audit" off
        9 "Run ClamAV Scan" off
        10 "Quit" off
    )

    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    clear

    for choice in $choices; do
        case $choice in
            1) run_auditing ;;
            2) configure_pam ;;
            3) configure_firewall ;;
            4) configure_ssh ;;
            5) manage_passwords ;;
            6) misc_checks ;;
            7) rootkit_check ;;
            8) run_lynis ;;
            9) run_clamav ;;
            10) echo "Exiting script."; exit ;;
        esac
    done

done
