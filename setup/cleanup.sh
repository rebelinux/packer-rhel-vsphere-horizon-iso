#!/bin/bash

# Author: Jonathan Colon
# Date Created: 10/04/2023
# Last Modified: 30/04/2023

# Description
# This script is the final sealing process. It is cleaning the machine preparing it for instant horizon cloning.

# Usage
# cleanup

# Remove Unneeded Packages
printf "===> Remove Unneeded Packages\n"
dnf remove -q -y gcc-c++ kernel-devel-$(uname -r) kernel-headers-$(uname -r) patch elfutils-libelf-devel make gnome-initial-setup 1> /dev/null

# Disable Automatic Updates
printf "===> Disable Automatic Updates\n"
systemctl stop packagekit > /dev/null
systemctl mask packagekit > /dev/null

# Disable System Not Registered notification from GNOME
printf "===> Disable System Not Registered notification from GNOME\n"
sed -i /lib/systemd/user/org.gnome.SettingsDaemon.Subscription.service -e 's/ExecStart=*/#ExecStart/g'

# "Cleaning all audit logs."
printf "===> Cleaning all audit logs.\n"
if [ -f /var/log/audit/audit.log ]; then
cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
cat /dev/null > /var/log/lastlog
fi

# "Cleaning persistent udev rules."
printf "===> Cleaning persistent udev rules.\n"
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
rm /etc/udev/rules.d/70-persistent-net.rules
fi

# "Cleaning the /tmp directories"
printf "===> Cleaning the /tmp directories\n"
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/dnf/*

# "Unregistering from Red Hat Subscription Manager."
printf "===> Unregistering from Red Hat Subscription Manager.\n"
subscription-manager unregister 1> /dev/null
subscription-manager clean 1> /dev/null

# "Cleaning the Red Hat Subscription Manager logs."
printf "===> Cleaning the Red Hat Subscription Manager logs.\n"
if [ -d /var/log/rhsm/ ]; then
rm -rf /var/log/rhsm/*
fi

# "Cleaning the SSH host keys."
printf "===> Cleaning the SSH host keys.\n"
rm -f /etc/ssh/ssh_host_*

# "Cleaning the machine-id."
printf "===> Cleaning the machine-id.\n"
truncate -s 0 /etc/machine-id

# "Cleaning the shell history."
printf "===> Cleaning the shell history.\n"
unset HISTFILE
history -cw
echo > ~/.bash_history
rm -fr /root/.bash_history

# "Running a sync."
printf "===> Running a sync.\n"
sync && sync