#!/bin/bash

# Author: Jonathan Colon
# Date Created: 10/04/2020
# Last Modified: 30/04/2020

# Description
# This script installs commonly used applications

# Usage
# packages

# Install Additional Packages
printf "===> Installing develepment and compile packages\n"
dnf install -q -y gcc-c++ kernel-devel-$(uname -r) kernel-headers-$(uname -r) patch elfutils-libelf-devel 1> /dev/null

if [ -z "$Additional_Packages" ]
then
    printf "===> Empty \$Aditional_Packages variable, disabling additional packages install\n"
else
    printf "===> Installing additional packages\n"
    dnf install -q -y $Additional_Packages 1> /dev/null
fi