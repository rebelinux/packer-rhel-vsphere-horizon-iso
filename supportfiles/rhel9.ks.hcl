# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Red Hat Enterprise Linux Server 9

### Installs from the first attached CD-ROM/DVD on the system.
cdrom

### Performs the kickstart installation in text mode. 
### By default, kickstart installations are performed in graphical mode.
text

### Accepts the End User License Agreement.
eula --agreed

### Sets the language to use during installation and the default language to use on the installed system.
lang ${vm_guest_os_language}

### Sets the default keyboard type for the system.
keyboard ${vm_guest_os_keyboard}

### Configure network information for target system and activate network devices in the installer environment (optional)
### --onboot	  enable device at a boot time
### --device	  device to be activated and / or configured with the network command
### --bootproto	  method to obtain networking configuration for device (default dhcp)
### --noipv6	  disable IPv6 on this device
###
### network  --bootproto=static --ip=172.16.11.200 --netmask=255.255.255.0 --gateway=172.16.11.200 --nameserver=172.16.11.4 --hostname centos-linux-8
network --bootproto=dhcp --hostname=${vm_hostname}

### Lock the root account.
rootpw --lock

### The selected profile will restrict root login.
### Add a user that can login and escalate privileges.
user --name=${build_username} --iscrypted --password=${build_password_encrypted} --groups=wheel

### Configure firewall settings for the system.
### --enabled	reject incoming connections that are not in response to outbound requests
### --ssh		allow sshd service through the firewall
firewall --enabled --ssh

### Sets up the authentication options for the system.
### The SSDD profile sets sha512 to hash passwords. Passwords are shadowed by default
### See the manual page for authselect-profile for a complete list of possible options.
authselect select sssd

### Sets up kdump to disable.
%addon com_redhat_kdump --disable
%end

### Sets the state of SELinux on the installed system.
### Defaults to enforcing.
selinux --enforcing

# Intended system purpose
syspurpose --role="Red Hat Enterprise Linux Workstation" --sla="Self-Support" --usage="Development/Test"

### Sets ntp time source .
timesource --ntp-server=${vm_ntp_server}

### Sets the system time zone.
timezone ${vm_guest_os_timezone}

### Sets how the boot loader should be installed.
bootloader --location=mbr

### Initialize any invalid partition tables found on disks.
zerombr

### Removes partitions from the system, prior to creation of new partitions. 
### By default, no partitions are removed.
### --linux	erases all Linux partitions.
### --initlabel Initializes a disk (or disks) by creating a default disk label for all disks in their respective architecture.
clearpart --all --initlabel

# Generated using Blivet version 3.4.0
ignoredisk --only-use=sda
autopart

### Modifies the default set of services that will run under the default runlevel.
services --enabled=NetworkManager,sshd

### Configure X on the installed system.
xconfig --startxonboot


### Packages selection.
%packages --ignoremissing --excludedocs
@core
-iwl*firmware
@^workstation-product-environment
@gnome-apps
@internet-applications
@office-suite
@system-tools
-gnome-initial-setup
%end

### Post-installation commands.
%post
# Register Redhat Subscription Manager
/usr/sbin/subscription-manager register --username ${rhsm_username} --password ${rhsm_password} --autosubscribe --force
/usr/sbin/subscription-manager repos --enable "codeready-builder-for-rhel-9-x86_64-rpms"
dnf install -y "https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm"
dnf makecache
dnf -y update
dnf install -y sudo open-vm-tools perl libappindicator-gtk3 krb5-workstation sssd adcli samba-common-tools oddjob oddjob-mkhomedir realmd

#To enable audio input and audio output redirection on a RHEL 9.x desktop, you must install the PulseAudio sound server on the source virtual machine, as described in the following procedure. By default, RHEL 9.x systems manage sound using the PipeWire server, which does not support audio redirection in remote sessions.
dnf swap -y --allowerasing pipewire-pulseaudio pulseaudio
dnf remove -y pipewire-alsa pipewire-jack-audio-connection-kit
dnf install -y alsa-plugins-pulseaudio
dnf install -y pulseaudio-module-x11 pulseaudio-utils

sed -i "/etc/crypto-policies/back-ends/krb5.config" -e 's/permitted_enctypes = aes256-cts-hmac-sha1-96 aes256-cts-hmac-sha384-192 aes128-cts-hmac-sha256-128 aes128-cts-hmac-sha1-96/permitted_enctypes = aes256-cts-hmac-sha1-96 aes256-cts-hmac-sha384-192 aes128-cts-hmac-sha256-128 aes128-cts-hmac-sha1-96 +rc4/g'
echo "${build_username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${build_username}
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
%end

### Reboot after the installation is complete.
### --eject attempt to eject the media before rebooting.
reboot --eject