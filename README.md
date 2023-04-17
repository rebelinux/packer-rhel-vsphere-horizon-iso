# packer-rhel-vsphere-horizon-iso

This repo builds automatically RHEL VM templates (RHEL 9.1) for VMware vSphere and Horizon environment using Hashicorp's Packer.

RHEL ISO files gets downloaded from vCenter Datastore.

## How to use this repo

### Pre-requesites

Download or `git clone https://github.com/rebelinux/packer-rhel-vsphere-horizon-iso` this repo and make sure you have [Packer](https://www.packer.io/downloads) Version 1.8.5 or later installed. If you don't know Packer, it's a single commandline binary which only needs to be on your `PATH`.

### Step 1: Adjust variables

Rename the file [variables.auto.pkrvars.hcl.sample](variables.auto.pkrvars.hcl.sample) to `variables.auto.pkrvars.hcl` and adjust the variables for your VMware vSphere environment. Some documentation on each variable is inside the sample file.

```bash
mv variables.auto.pkrvars.hcl.sample variables.auto.pkrvars.hcl
nano variables.auto.pkrvars.hcl
```

### Step 2: Init Packer

Init Packer by using the following command. (Spot the dot at the end of the command!)

```bash
packer init .
```

### Step 3: Build a VM Template

To build a VM template run one of the provided `build`-scripts.
For example to build a RHEL Server 20.04 template run:

```bash
./build-rhel9.sh
```

If you are on a Windows machine then use the `build-rhel9.ps1` files.

```powershell
./build-rhel9.ps1
```

### Optional: Template default credentials

The default credentials after a successful build are
Username: `godadmin`
Password: `godadmin`  

If you would like to change the default credentials before a packer build, then you need to edit the following files:

- **variables.auto.pkrvars.hcl** (Line 41:49)

To generate an encrypted password use the following command:

```bash
mkpasswd -m SHA-512 --rounds=4096
```
