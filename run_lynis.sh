#!/bin/bash

echo 'Running Lynis security audit...'
output="$HOME/LYNIS.txt"
sudo lynis audit system | sudo tee "$output"
