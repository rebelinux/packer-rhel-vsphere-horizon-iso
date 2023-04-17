#!/bin/bash

# "Cleaning all audit logs."
echo "===> "Cleaning all audit logs.""
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
echo "===> Cleaning persistent udev rules."
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
rm /etc/udev/rules.d/70-persistent-net.rules
fi

# "Cleaning the /tmp directories"
echo "===> Cleaning the /tmp directories"
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/dnf/*

# "Unregistering from Red Hat Subscription Manager."
echo "===> Unregistering from Red Hat Subscription Manager."
subscription-manager unregister
subscription-manager clean

# "Cleaning the Red Hat Subscription Manager logs."
echo "===> Cleaning the Red Hat Subscription Manager logs."
if [ -d /var/log/rhsm/ ]; then
rm -rf /var/log/rhsm/*
fi

# "Cleaning the SSH host keys."
echo "===> Cleaning the SSH host keys."
rm -f /etc/ssh/ssh_host_*

# "Cleaning the machine-id."
echo "===> Cleaning the machine-id."
truncate -s 0 /etc/machine-id

# "Cleaning the shell history."
echo "===> Cleaning the shell history."
unset HISTFILE
history -cw
echo > ~/.bash_history
rm -fr /root/.bash_history

# "Running a sync."
echo "===> Running a sync."
sync && sync