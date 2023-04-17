packer {
  required_version = ">= 1.8.5"
  required_plugins {
    vsphere = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

variable "rhsm_username" {
  type        = string
  description = "The username to Red Hat Subscription Manager."
  sensitive   = true
}

variable "rhsm_password" {
  type        = string
  description = "The password to login to Red Hat Subscription Manager."
  sensitive   = true
}

variable "vm_guest_os_language" {
  type        = string
  description = "The guest operating system lanugage."
  default     = "en_US"
}

variable "vm_guest_os_keyboard" {
  type        = string
  description = "The guest operating system keyboard input."
  default     = "us"
}

variable "vm_guest_os_timezone" {
  type        = string
  description = "The guest operating system timezone."
  default     = "UTC"
}

variable "join_password" {
  type =  string
  default = ""
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "join_username" {
  type =  string
  default = "Administrator"
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "ad_domain" {
  type =  string
  default = ""
  // Sensitive vars are hidden from output as of Packer v1.6.5
}

variable "ntp_server" {
  type =  string
  default = ""
}

variable "horizon_agent_file" {
  type =  string
  default = ""
}

variable "horizon_agent_path" {
  type =  string
  default = ""
}

variable "horizon_agent_datastore" {
  type =  string
  default = ""
}

variable "timezone" {
  type =  string
  default = "Etc/UTC"
}

variable "cpu_num" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = number
  default = 51200
}

variable "mem_size" {
  type    = number
  default = 4096
}

variable "os_iso_checksum" {
  type    = string
  default = ""
}

variable "os_iso_url" {
  type    = string
  default = ""
}

variable "iso_path" {
  # type    = string
  description = "The path on the source vSphere datastore for ISO images."
  default = []
  }

variable "vsphere_folder" {
  type    = string
  default = ""
}

variable "vsphere_datastore" {
  type    = string
  default = ""
}

variable "vsphere_datacenter" {
  type    = string
  default = ""
}

variable "vsphere_guest_os_type" {
  type    = string
  default = ""
}

variable "vsphere_host" {
  type    = string
  default = ""
}

variable "vsphere_cluster" {
  type    = string
  default = ""
}

variable "vsphere_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "vsphere_network" {
  type    = string
  default = ""
}

variable "vsphere_server" {
  type    = string
  default = ""
}

variable "vsphere_vm_name" {
  type    = string
  default = ""
}

variable "vsphere_username" {
  type    = string
  default = ""
}

variable "ssh_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "ssh_username" {
  type    = string
  default = ""
}

variable "shell_scripts" {
  type = list(string)
  description = "A list of scripts."
  default = []
}

variable "boot_command" {
  type = list(string)
  description = "RHEL boot command"
  default = []
}

// Communicator Settings and Credentials

variable "build_username" {
  type        = string
  description = "The username to login to the guest operating system. (e.g. 'rainpole')"
  sensitive   = true
}

variable "build_password" {
  type        = string
  description = "The password to login to the guest operating system."
  sensitive   = true
}

variable "build_password_encrypted" {
  type        = string
  description = "The SHA-512 encrypted password to login to the guest operating system."
  sensitive   = true
}


locals {
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  data_source_content = {
  "/ks.cfg" = templatefile("./supportfiles/rhel9.ks.hcl", {
      build_username           = var.build_username
      build_password           = var.build_password
      build_password_encrypted = var.build_password_encrypted
      rhsm_username            = var.rhsm_username
      rhsm_password            = var.rhsm_password
      vm_guest_os_language     = var.vm_guest_os_language
      vm_guest_os_keyboard     = var.vm_guest_os_keyboard
      vm_guest_os_timezone     = var.vm_guest_os_timezone
      vm_ntp_server            = var.ntp_server
      vm_hostname              = var.vsphere_vm_name
      })
    }
}

source "vsphere-iso" "rhel" {
  notes = "Built by HashiCorp Packer on ${local.buildtime}."
  folder = var.vsphere_folder
  vcenter_server        = var.vsphere_server
  #host                  = var.vsphere_host
  cluster               = var.vsphere_cluster
  username              = var.vsphere_username
  password              = var.vsphere_password
  insecure_connection   = "true"
  datacenter            = var.vsphere_datacenter
  datastore             = var.vsphere_datastore

  CPUs                  = var.cpu_num
  RAM                   = var.mem_size
  RAM_reserve_all       = true
  disk_controller_type  = ["pvscsi"]
  guest_os_type         = "rhel9_64Guest"
  iso_paths = var.iso_path
  remove_cdrom          = true

  cd_content              = local.data_source_content
  cd_label              = "supportfiles"

  network_adapters {
    network             = var.vsphere_network
    network_card        = "vmxnet3"
  }

  storage {
    disk_size             = var.disk_size
    disk_thin_provisioned = true
  }

  vm_name               = var.vsphere_vm_name
  convert_to_template   = "false"
  create_snapshot       = "true"
  snapshot_name         = "Horizon IC SnapShot"
  communicator          = "ssh"
  ssh_username          = var.build_username
  ssh_password          = var.build_password
  ssh_timeout           = "60m"
  ssh_handshake_attempts = "100000"

  boot_order            = "disk,cdrom,floppy"
  boot_wait             = "3s"
  boot_command          = var.boot_command
  shutdown_command      = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout      = "15m"

  configuration_parameters = {
    "disk.EnableUUID" = "true",
    "svga.autodetect": "true",
    "logging": "false"
  }
}

build {
  sources = ["source.vsphere-iso.rhel"]

  // Uncomment this to copy horizon files from vcenter datastore and used it as a web server.
  // This part of the code download the horizon agent from a datastore from Vcenter/ESXi host.
  // To get the file URL use the vcenter "Browse datastores in the vSphere inventory" tool.
  // IS your responsability to construct the URL correctly. Good Luck!
  provisioner "shell" {
    inline = [
      "curl -k --user '${var.vsphere_username}:${var.vsphere_password}' -X GET -o ./${var.horizon_agent_file} --output-dir '/tmp/' 'https://${var.vsphere_server}/folder${var.horizon_agent_path}${var.horizon_agent_file}?dcPath=${var.vsphere_datacenter}&dsName=${var.horizon_agent_datastore}'" 
      ]
  }

  // Uncomment this to copy local horizon files from ./file/ to /tmp
  // This other option permit to copy the horizon agent installation file from the /files local directory.
  // This allow to upload the file to the VM and copy it to the /tmp folder. Good Luck!
  provisioner "file" {
    source = "./files/"
    destination = "/tmp/"
  }
  
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    environment_vars = [
      "BUILD_USERNAME=${var.build_username}",
      "JOINUSERNAME=${var.join_username}",
      "JOINPASSWORD=${var.join_password}",
      "NTPSERVER=${var.ntp_server}",
      "ADDomain=${var.ad_domain}",
      "HORIZONAGENTFILE=${var.horizon_agent_file}"
    ]
    scripts = var.shell_scripts
    expect_disconnect = true
  }
}
