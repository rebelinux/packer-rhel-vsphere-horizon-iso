#!/bin/bash

# Extracting VMware Horizon Agent files
if [ -f "/tmp/$HORIZONAGENTFILE" ]
then
    echo "===> Extracting VMware Horizon Agent files to /tmp/hzagentdir directory"
    if [ ! -f "/tmp/hzagentdir" ] 
    then
        echo "===> Creating /tmp/hzagentdir directory"
        mkdir "/tmp/hzagentdir"
    else
        echo "===> Error: Unable to create /tmp/hzagentdir directory"
    fi 
    tar -zxf "/tmp/$HORIZONAGENTFILE" -C "/tmp/hzagentdir" --strip-components=1 --overwrite

    cd "/tmp/"

    # Downloading V4L2Loopback driver files
    echo "===> Downloading v4l2loopback driver files"
    wget --quiet "https://github.com/umlaeute/v4l2loopback/archive/refs/tags/v0.12.5.tar.gz"
    # Downloading VHCI-HCD driver files
    echo "===> Downloading VHCI-HCD driver files"
    wget --quiet https://sourceforge.net/projects/usb-vhci/files/linux%20kernel%20module/vhci-hcd-1.15.tar.gz/download -O "vhci-hcd-1.15.tar.gz"

    tar -zxf "vhci-hcd-1.15.tar.gz"
    
    # Adding support for Horizon Real-Time Audio-Video
    if [ -f "/tmp/v0.12.5.tar.gz" ] && [ -d "/tmp/hzagentdir" ]
    then
        # Extracting V4L2Loopback driver files
        echo "===> Extracting V4L2Loopback driver files"
        tar -zxf "v0.12.5.tar.gz" --overwrite

        # Patching V4L2Loopback driver files
        echo "===> Patching V4L2Loopback driver files"
        cd "/tmp/v4l2loopback-0.12.5/"
        patch -p1 < "/tmp/hzagentdir/resources/v4l2loopback/v4l2loopback.patch"

        # Compiling V4L2Loopback driver files
        echo "===> Extracting V4L2Loopback driver files"
        make clean && make && make install

        # Installing v4l2loopback-ctl
        echo "===> Installing v4l2loopback-ctl"
        make install-utils
        depmod -A
    else
        echo "===> Error: File v0.12.5.tar.gz does not exists."
        echo "===> Error: Unable to compile and install V4L2Loopback driver"
        echo "===> Error: Disable support for Horizon Real-Time Audio-Video"
    fi

    # Adding support for Horizon USB redirection
    if [ -f "/tmp/vhci-hcd-1.15.tar.gz" ] && [ -d "/tmp/hzagentdir" ]
    then
        # Extracting VHCI-HCD driver files
        echo "===> Extracting VHCI-HCD driver files"
        cd "/tmp/"
        tar -zxf "vhci-hcd-1.15.tar.gz" --overwrite

        # Patching VHCI-HCD driver files
        echo "===> Patching VHCI-HCD driver files"
        cd "/tmp/vhci-hcd-1.15"
        patch -p1 < "/tmp/hzagentdir/resources/vhci/patch/vhci.patch"

        # Compiling VHCI-HCD driver files
        echo "===> Compiling VHCI-HCD driver files"
        make clean && make && make install
    else
        echo "===> Error: File vhci-hcd-1.15.tar.gz does not exists."
        echo "===> Error: Unable to compile and install VHCI-HCD driver"
        echo "===> Error: Disable support for Horizon USB redirection"
    fi

    # Installing Horizon Agent
    if [ -d "/tmp/hzagentdir" ]
    then
        echo "===> Installing Horizon Agent"
        cd "/tmp/hzagentdir"

        echo "===> Looking for vhci-hcd driver status"
        if [ -f "/usr/lib/modules/$(uname -r)/kernel/drivers/usb/usbip/vhci-hcd.ko" ]
        then
            echo "===> Found vhci-hcd driver, enabling Horizon USB redirection"
            INSTALL_OPTIONS="-A yes -U yes"
        else 
            echo "===> Driver vhci-hcd not installed, disabling Horizon USB redirection"
            INSTALL_OPTIONS="-A yes"
        fi

        echo "===> Looking for V4L2Loopback driver status"
        if [ -f "/lib/modules/$(uname -r)/extra/v4l2loopback.ko" ]
        then
            echo "===> Found V4L2Loopback driver, enabling Horizon Real-Time Audio-Video"
            INSTALL_OPTIONS="$INSTALL_OPTIONS -a yes --webcam"
        else 
            echo "===> Driver V4L2Loopback not installed, disabling Horizon Real-Time Audio-Video"
        fi

        echo "===> Using install options: $INSTALL_OPTIONS"

        ./install_viewagent.sh $INSTALL_OPTIONS

    else
        echo "===> Error: Directory /tmp/hzagentdir does not exists."
        echo "===> Error: Unable to install Horizon"
    fi

    # Setting SSSD authentication (OfflineJoinDomain=sssd)
    if [ -f "/etc/vmware/viewagent-custom.conf" ]
    then
        echo "===> Setting SSSD authentication (OfflineJoinDomain=sssd)"
        echo "OfflineJoinDomain=sssd" >> "/etc/vmware/viewagent-custom.conf"
    else
        echo "===> Error: File /etc/vmware/viewagent-custom.conf does not exists."
    fi
else
    echo "===> Error: $HORIZONAGENTFILE File does not exists."
    echo "===> Error: Unable to extract VMware Horizon Agent files"
fi