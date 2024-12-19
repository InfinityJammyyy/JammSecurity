#!/bin/bash

echo 'Configuring LightDM...'
backup_file /etc/lightdm/lightdm.conf
cat <<EOL | sudo tee /etc/lightdm/lightdm.conf
allow-guest=false
greeter-hide-users=true
greeter-show-manual-login=true
autologin-user=none
EOL
