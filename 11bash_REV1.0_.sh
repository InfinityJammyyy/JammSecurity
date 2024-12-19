#!/bin/bash

if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script as root (sudo)"
    exit 1
fi

sudo -v || { echo "Sudo privileges required."; exit 1; }

echo ''
echo '      ██                                  '
echo '     ░██                                  '
echo '     ░██  ██████   ██████████  ██████████ '
echo '     ░██ ░░░░░░██ ░░██░░██░░██░░██░░██░░██'
echo '     ░██  ███████  ░██ ░██ ░██ ░██ ░██ ░██'
echo ' ██  ░██ ██░░░░██  ░██ ░██ ░██ ░██ ░██ ░██'
echo '░░█████ ░░████████ ███ ░██ ░██ ███ ░██ ░██'
echo ' ░░░░░   ░░░░░░░░ ░░░  ░░  ░░ ░░░  ░░  ░░ '
echo '  ████████                                ██   ██           '
echo ' ██░░░░░░                                ░░   ░██    ██   ██'
echo '░██         █████   █████  ██   ██ ██████ ██ ██████ ░░██ ██ '
echo '░█████████ ██░░░██ ██░░░██░██  ░██░░██░░█░██░░░██░   ░░███  '
echo '░░░░░░░░██░███████░██  ░░ ░██  ░██ ░██ ░ ░██  ░██     ░██   '
echo '       ░██░██░░░░ ░██   ██░██  ░██ ░██   ░██  ░██     ██    '
echo ' ████████ ░░██████░░█████ ░░██████░███   ░██  ░░██   ██     '
echo '░░░░░░░░   ░░░░░░  ░░░░░   ░░░░░░ ░░░    ░░    ░░   ░░     '
echo ''

sudo apt update -y && sudo apt upgrade -y && sudo apt install -y dialog mawk

./install_packages.sh
./userman.sh

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
            1) ./run_auditing.sh ;;
            2) ./configure_pam_pwquality.sh ;;
            3) ./configure_firewall.sh ;;
            4) ./configure_ssh.sh ;;
            5) ./manage_passwords.sh ;;
            6) ./misc_checks.sh ;;
            7) ./rootkit_check.sh ;;
            8) ./run_lynis.sh ;;
            9) ./run_clamav.sh ;;
            10) ./set_proper_perms.sh ;;
            11) ./configure_lightdm.sh ;;
        esac
    done

    break
done

echo "All selected tasks completed. Exiting script."
exit 0
