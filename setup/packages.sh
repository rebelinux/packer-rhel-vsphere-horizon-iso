#!/bin/bash

# Install Additional Packages
echo "===> Installing additional packages"
dnf install -q -y gcc-c++ kernel-devel-$(uname -r) kernel-headers-$(uname -r) patch elfutils-libelf-devel gimp

# Install Google Chrome Package
echo "===> Install Google Chrome Package"
dnf install -q -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

# Install Microsoft Repo and key Package
echo "===> Install Microsoft Repo and key Package"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Install Microsoft VSCode
echo "===> Install Microsoft VSCode"
dnf -q check-update
dnf install -q -y code
