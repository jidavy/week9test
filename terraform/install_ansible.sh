#!/bin/bash
# Update the system
dnf update -y

# Install Ansible
dnf install -y ansible-core

# Verify installation (logs to /var/log/user-data.log)
ansible --version