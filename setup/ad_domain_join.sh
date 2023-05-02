#!/bin/bash

# Author: Jonathan Colon
# Date Created: 10/04/2023
# Last Modified: 30/04/2023

# Description
# First the script points the machine to the NTP server of the $NTPSERVER domain then adds the linux machine to the domain specified in the $ADDomain variable. 
# Finally it configures the automatic creation of the home directory for the users of the network

# Usage
# ad_domain_join

# Join AD Domain
printf "===> Pointing NTP Server to %s Domain\n" "$ADDomain"
echo $JOINPASSWORD | sudo realm join --user=$JOINUSERNAME $ADDomain 

retval=$?
if [ $retval -ne 0 ] 
then
    printf "===> Unable to add machine to domain %s \n" "$ADDomain"
else 
    # Disable use_fully_qualified_names in AD Login
    printf "===> Disable use_fully_qualified_names in AD Login\n"
    sed -i /etc/sssd/sssd.conf -e 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g'

    # Add this line for SSO Login
    printf "===> Disable use_fully_qualified_names in AD Login\n"
    echo "ad_gpo_map_interactive = +gdm-vmwcred" >> /etc/sssd/sssd.conf
    echo "ad_gpo_access_control = permissive" >> /etc/sssd/sssd.conf
fi