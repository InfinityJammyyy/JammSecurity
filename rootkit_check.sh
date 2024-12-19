#!/bin/bash

echo 'Checking for rootkits...'
output="$HOME/Rootkit.txt"
sudo chkrootkit | sudo tee "$output"
sudo rkhunter --update | sudo tee -a "$output"
sudo rkhunter --check | sudo tee -a "$output"
