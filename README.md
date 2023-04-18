# :beginner: packer-rhel-vsphere-horizon-iso

This repo builds automatically RHEL VM templates (RHEL 22.04) for VMware vSphere and Horizon environment using Hashicorp's Packer.

RHEL ISO files gets downloaded from vCenter Datastore.

## :books: How to use this repo

### :wrench: Pre-requesites

Download or `git clone https://github.com/rebelinux/packer-rhel-vsphere-horizon-iso` this repo and make sure you have [Packer](https://www.packer.io/downloads) Version 1.8.5 or later installed. If you don't know Packer, it's a single commandline binary which only needs to be on your `PATH`.

### Step 1: Adjust variables

Rename the file [variables.auto.pkrvars.hcl.sample](variables.auto.pkrvars.hcl.sample) to `variables.auto.pkrvars.hcl` and adjust the variables for your VMware vSphere environment. Some documentation on each variable is inside the sample file.

```bash
mv variables.auto.pkrvars.hcl.sample variables.auto.pkrvars.hcl
nano variables.auto.pkrvars.hcl
```

#### Option 1: Local Horizon Agent File (Default)

Copy the Horizon Agent installation file to the `./files/` folder:

```bash
[rebelinux@rebelpc packer-rhel-vsphere-horizon-iso]$ ls -alh files/
total 127M
-rw-r--r-- 1 0 Apr 13 21:20 Place_Here_Horizon_Agent_Files.txt
-rw-r--r-- 1 127M Apr 10 08:31 "VMware-horizonagent-linux-x86_64-2303-8.9.0-21434177.tar.gz"
[rebelinux@rebelpc packer-rhel-vsphere-horizon-iso]$
```

#### Option 2: Use vCenter as a Web Server to host Horizon Agent File

Save the Horizon agent installation files to a staging Datastore

![Sample vSphere Staging Datastore](https://raw.githubusercontent.com/rebelinux/IMG/main/VMware_horizon_agent%20package.png "Sample vSphere Staging Datastore")

Get the Horizon agent file URL from the `Browse datastores in the vSphere inventory`

![Copy URL](https://raw.githubusercontent.com/rebelinux/IMG/main/Datastore_URL.png "Copy URL")

Next, uncomment line (292:296) and paste the vCenter URL like the provided example:

```bash
  provisioner "shell" {
   inline = [
     "curl -k --user '${var.vsphere_username}:${var.vsphere_password}' -X GET -o ./${var.horizon_agent_file} --output-dir '/tmp/' 'https://vcenter-01v.lab.local/folder/ISO%2fVMWARE%2fHorizon/VMware-horizonagent-linux-x86_64-2303-8.9.0-21434177.tar.gz?dcPath=PHARMAX-VSI-DC&dsName=HDD-VM-ISO-LOW-PERF'" 
     ]
  }
```

### Step 2: Init Packer

Init Packer by using the following command. (Spot the dot at the end of the command!)

```bash
packer init .
packer validate .
```

### Step 3: Build a VM Template

To build a VM template run one of the provided `build`-scripts.
For example to build a RHEL 9.1 template run:

```bash
./build-rhel9.sh
```

If you are on a Windows machine then use the `build-rhel9.ps1` files.

```powershell
./build-rhel9.ps1
```

### :computer: Optional: Template default credentials

The default credentials after a successful build are
Username: `godadmin`
Password: `godadmin`  

If you would like to change the default credentials before a packer build, then you need to edit the following files:

- **variables.auto.pkrvars.hcl** (Line 41:49)

To generate an encrypted password use the following command:

```bash
mkpasswd -m SHA-512 --rounds=4096
```

### :clipboard: Template Variables

```sh
# Name or IP of you vCenter Server
vsphere_server          = "vcenter.demolab.com"

# vsphere username
vsphere_username        = "administrator@vsphere.local"

# vsphere password
vsphere_password        = "SomeSecurePassword"

# vsphere datacenter name
vsphere_datacenter      = "datacenter1"

# vsphere cluster name
vsphere_cluster           = "esx1.demolab.com"

# vsphere folder name
vsphere_folder           = "folder"

# vsphere network
vsphere_network         = "VM Network"

# vsphere datastore
vsphere_datastore       = "datastore1"

# vsphere VM Name
vsphere_vm_name         = "hz-tpl-rhel-9"

# RHEL boot command
boot_command            = ["<up><wait><tab><wait> inst.text inst.ks=cdrom:/ks.cfg <enter><wait>"]

# final clean up script
shell_scripts           = [
    "./setup/packages.sh",
    "./setup/desktop_postinstall.sh",
    "./setup/ad_domain_join.sh",
    "./setup/horizon_agent_install.sh",
    "./setup/cleanup.sh"
    ]

# RHEL OS Settings
vm_guest_os_language = "en_US.UTF-8"
vm_guest_os_keyboard = "us"
vm_guest_os_timezone = "UTC"

# SSH username
build_username = "godadmin"

# SSH password
build_password = "godadmin"

build_password_encrypted = "$6$rounds=4096$Y0SjrsU5WHubYJvb$0BJhswGEAokE2OqlRFTgiUhJnquzDt2hAnrb3.g3DNTATZ01VLNbxlLRLMLk.PTHiMeP8fUg9WfVx.HeL7e8E0"

# ISO Objects
iso_path = ["[vmware-nfs] /iso/rhel-baseos-9.1-x86_64-dvd.iso"]

# NTP Server
ntp_server = "changeme"

# AD Domain
ad_domain = "CHANGEME"

# AD Domain join password
join_password = "changeme"

# AD Domain join username
join_username = "changeme"

# Horizon Agent install file location
# horizon_agent_datastore = "HDD-VM-ISO-LOW-PERF"
# horizon_agent_path = "/ISO/VMWARE/Horizon/"
# horizon_agent_file = "VMware-horizonagent-linux-x86_64-2303-8.9.0-21434177.tar.gz"

# The credential to register Red Hat Subscription Manager
rhsm_username = "changeme"
rhsm_password = "changeme"
```
