#!/bin/bash

# Author: Jonathan Colon
# Date Created: 10/04/2023
# Last Modified: 30/04/2023

# Description
# The main purpose of this script is to install and configure the Horizon Agent for linux. The script tries its best to 
# compile support for USB and Real-Time Audio-Video redirection.

# Usage
# horizon_agent_install

# Extracting VMware Horizon Agent files
if [ -f "/tmp/$HORIZONAGENTFILE" ]
then
    printf "===> Extracting VMware Horizon Agent files to /tmp/hzagentdir directory\n"
    if [ ! -f "/tmp/hzagentdir" ] 
    then
        printf "===> Creating /tmp/hzagentdir directory\n"
        mkdir "/tmp/hzagentdir"
    else
        printf "===> Error: Unable to create /tmp/hzagentdir directory\n"
    fi 
    tar -zxf "/tmp/$HORIZONAGENTFILE" -C "/tmp/hzagentdir" --strip-components=1 --overwrite

    retval="$?"
    if [ $retval -ne 0 ] 
    then
        printf "Unable to extract %s needed for the install of horizon agent for linux\n" "$HORIZONAGENTFILE"
    else
        cd "/tmp/"

        # Downloading V4L2Loopback driver files
        printf "===> Downloading v4l2loopback driver files\n"
        wget --quiet "https://github.com/umlaeute/v4l2loopback/archive/refs/tags/v0.12.5.tar.gz"
        # Downloading VHCI-HCD driver files
        printf "===> Downloading VHCI-HCD driver files\n"
        wget --quiet https://sourceforge.net/projects/usb-vhci/files/linux%20kernel%20module/vhci-hcd-1.15.tar.gz/download -O "vhci-hcd-1.15.tar.gz"

        tar -zxf "vhci-hcd-1.15.tar.gz"
        
        # Adding support for Horizon Real-Time Audio-Video
        if [ -f "/tmp/v0.12.5.tar.gz" ] && [ -d "/tmp/hzagentdir" ]
        then
            # Extracting V4L2Loopback driver files
            printf "===> Extracting V4L2Loopback driver files\n"
            tar -zxf "v0.12.5.tar.gz" --overwrite

            # Patching V4L2Loopback driver files
            printf "===> Patching V4L2Loopback driver files\n"
            cd "/tmp/v4l2loopback-0.12.5/"
            patch -p1 < "/tmp/hzagentdir/resources/v4l2loopback/v4l2loopback.patch" 1> /dev/null

            # Compiling V4L2Loopback driver files
            printf "===> Extracting V4L2Loopback driver files\n"
            make clean > /dev/null && make > /dev/null && make install > /dev/null

            # Installing v4l2loopback-ctl
            printf "===> Installing v4l2loopback-ctl\n"
            make install-utils 1> /dev/null
            depmod -A 1> /dev/null
        else
            printf "===> Error: File v0.12.5.tar.gz does not exists.\n"
            printf "===> Error: Unable to compile and install V4L2Loopback driver\n"
            printf "===> Error: Disable support for Horizon Real-Time Audio-Video\n"
        fi

        # Adding support for Horizon USB redirection
        if [ -f "/tmp/vhci-hcd-1.15.tar.gz" ] && [ -d "/tmp/hzagentdir" ]
        then
            # Extracting VHCI-HCD driver files
            printf "===> Extracting VHCI-HCD driver files\n"
            cd "/tmp/"
            tar -zxf "vhci-hcd-1.15.tar.gz" --overwrite 

            # Patching VHCI-HCD driver files
            printf "===> Patching VHCI-HCD driver files\n"
            cd "/tmp/vhci-hcd-1.15"
            patch -p1 < "/tmp/hzagentdir/resources/vhci/patch/vhci.patch" 1> /dev/null

            # Compiling VHCI-HCD driver files
            printf "===> Compiling VHCI-HCD driver files\n"
            make clean > /dev/null && make > /dev/null && make install > /dev/null
        else
            printf "===> Error: File vhci-hcd-1.15.tar.gz does not exists.\n"
            printf "===> Error: Unable to compile and install VHCI-HCD driver\n"
            printf "===> Error: Disable support for Horizon USB redirection\n"
        fi

        # Installing Horizon Agent
        if [ -d "/tmp/hzagentdir" ]
        then
            printf "===> Installing Horizon Agent\n"
            cd "/tmp/hzagentdir"

            printf "===> Looking for vhci-hcd driver status\n"
            if [ -f "/usr/lib/modules/$(uname -r)/kernel/drivers/usb/host/usb-vhci-hcd.ko" ]
            then
                printf "===> Found vhci-hcd driver, enabling Horizon USB redirection\n"
                INSTALL_OPTIONS="-A yes -U yes"
            else 
                printf "===> Driver vhci-hcd not installed, disabling Horizon USB redirection\n"
                INSTALL_OPTIONS="-A yes"
            fi

            printf "===> Looking for V4L2Loopback driver status\n"
            if [ -f "/lib/modules/$(uname -r)/extra/v4l2loopback.ko" ]
            then
                printf "===> Found V4L2Loopback driver, enabling Horizon Real-Time Audio-Video\n"
                INSTALL_OPTIONS="$INSTALL_OPTIONS -a yes --webcam"
            else 
                printf "===> Driver V4L2Loopback not installed, disabling Horizon Real-Time Audio-Video\n"
            fi

            printf "===> Using install options: %s\n" "$INSTALL_OPTIONS"

            ./install_viewagent.sh $INSTALL_OPTIONS 1> /dev/null

            retval=$?
            if [ $retval -ne 0 ] 
            then
                printf "===> Unable to install Horizon Agent for Linux\n"
            else
                printf "===> Horizon Agent for Linux installed successfully\n"
            fi

        else
            printf "===> Error: Directory /tmp/hzagentdir does not exists.\n"
            printf "===> Error: Unable to install Horizon\n"
        fi

        # Setting SSSD authentication (OfflineJoinDomain=sssd)
        if [ -f "/etc/vmware/viewagent-custom.conf" ]
        then
            printf "===> Setting SSSD authentication (OfflineJoinDomain=sssd)\n"
            echo "OfflineJoinDomain=sssd" >> "/etc/vmware/viewagent-custom.conf"
        else
            printf "===> Error: File /etc/vmware/viewagent-custom.conf does not exists.\n"
        fi
    fi
else
    printf "===> Error: %s File does not exists.\n" "$HORIZONAGENTFILE"
    printf "===> Error: Unable to extract VMware Horizon Agent files\n"
fi