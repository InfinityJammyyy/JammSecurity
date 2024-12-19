#!/bin/bash

echo 'Setting up auditing...'
sudo systemctl enable auditd
sudo auditctl -e 1
