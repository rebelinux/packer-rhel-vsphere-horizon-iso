#!/bin/bash

# Author: Jonathan Colon
# Date Created: 10/04/2023
# Last Modified: 30/04/2023

# Description
# This script install third-party applications

# Usage
# applications_install

if [ "$Google_Chrome_Install" ]
then 
    printf "===> Downloading Google Chrome install package.\n"
    wget --quiet "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"

    retval=$?

    if [ $retval -ne 0 ]
    then
        printf "===> Unable to install Google Chrome Web browser. Failed to download binary files.\n"
    else
        if [ -f "google-chrome-stable_current_x86_64.rpm" ] 
        then 
            printf "===> Google Chrome binary file found, trying to install it.\n"
            dnf -q -y install ./google-chrome-stable_current_x86_64.rpm 1> /dev/null
            retval=$?
            if [ $retval -ne 0 ]
            then 
                printf "===> Unable to install Google Chrome.\n"
            else 
                printf "===> Google Chrome successfully installed.\n"
            fi
        else 
            printf "===> Unable to locate Google Chrome install file.\n"
        fi
    fi
else
    printf "===> Google Chrome installation disabled.\n"
fi

sleep 5

if [ "$Mozilla_Firefox_Install" ]
then 
    printf "===> Installing Mozilla Firefox package.\n"
    dnf -q -y install firefox 1> /dev/null

    retval=$?
    if [ $retval -ne 0 ]
    then 
        printf "===> Unable to install Mozilla Firefox.\n"
    else
        printf "===> Mozilla Firefox successfully installed.\n"
    fi
else
    printf "===> Mozilla Firefox installation disabled.\n"
fi

sleep 5

if [ "$Microsoft_VSCode_Install" ]
then 
    printf "===> Downloading Microsoft VSCode install package.\n"
    wget --quiet -O vscode.rpm "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"

    retval=$?

    if [ $retval -ne 0 ]
    then
        printf "===> Unable to install Microsoft VSCode. Failed to download binary files.\n"
    else
        if [ -f "vscode.rpm" ] 
        then 
            printf "===> Microsoft VSCode binary file found, trying to install it.\n"
            dnf -q -y install ./vscode.rpm 1> /dev/null
            retval=$?
            if [ $retval -ne 0 ]; 
            then
                printf "===> Unable to install Microsoft VSCode.\n" 
            else
                printf "===> Microsoft VSCode successfully installed.\n"
            fi
        else 
            printf "===> Unable to locate Microsoft VSCode install file.\n"
        fi
    fi
else
    printf "===> Microsoft VSCode installation disabled.\n"
fi

sleep 5