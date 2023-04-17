#!/bin/bash

# Disable Ubuntu AutoUpdate
# echo '> Disable invalid v4l2loopback driver...'
# echo "override v4l2loopback * extra" >> /etc/depmod.d/ubuntu.conf
# depmod -A
# sudo rmmod v4l2loopback

# Install Additional Packages
# echo "===> Installing additional packages"
dnf install -y gcc-c++ kernel-devel-$(uname -r) kernel-headers-$(uname -r) patch elfutils-libelf-devel
