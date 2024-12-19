#!/bin/bash

echo 'Running ClamAV scan...'
output="$HOME/ClamAV_Report.txt"
sudo freshclam
sudo clamscan --infected --remove --recursive / | sudo tee "$output"
