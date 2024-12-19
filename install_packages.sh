#!/bin/bash

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
                5) sudo apt install -y libpam-pwquality libpam-modules ;;
                6) sudo apt install -y auditd ;;
                7) sudo apt install -y chkrootkit ;;
                8) sudo apt install -y rkhunter ;;
            esac
        done

        break
    done
}
