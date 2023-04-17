#!/bin/bash

# Enable ssh password auth and permit root login
echo "===> Enable ssh password auth and permit root login"
sudo sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i -e 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config

# Add user to sudoers file
echo "===> Add user to sudoers file"
echo ""%domain admins" ALL=(ALL) ALL" > "/etc/sudoers.d/$ADDomain"

# Change "/etc/sudoers.d/$ADDomain" permissions
echo "===> Change "/etc/sudoers.d/$ADDomain" permissions"
chmod 440 "/etc/sudoers.d/$ADDomain"   

# Change "Disabling SELinux."
echo "===> Disabling SELinux."
sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Updating MLocate database
if [ -f /usr/bin/updatedb ];
then
    echo "===> Updating MLocate database"
    updatedb
fi