#!/bin/bash

# Author: Jonathan Colon
# Date Created: 10/04/2023
# Last Modified: 30/04/2023

# Description
# This script modified content related to authentication (ssh & sudoers)

# Usage
# desktop_postinstall

# Enable ssh password auth and permit root login
printf "===> Enable ssh password auth and permit root login\n"
sudo sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i -e 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# Add user to sudoers file
printf "===> Add user to sudoers file\n"
echo ""%domain admins" ALL=(ALL) ALL" > "/etc/sudoers.d/$ADDomain"

# Change "/etc/sudoers.d/$ADDomain" permissions
printf "===> Change /etc/sudoers.d/%s permissions\n" "$ADDomain"
chmod 440 "/etc/sudoers.d/$ADDomain"   

# Change "Disabling SELinux."
printf "===> Disabling SELinux.\n"
sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Updating MLocate database
if [ -f /usr/bin/updatedb ];
then
    printf "===> Updating MLocate database\n"
    updatedb
fi