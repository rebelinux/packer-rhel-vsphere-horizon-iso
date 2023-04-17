#!/bin/bash
# variable files ending with .auto.pkrvars.hcl are automatically loaded

# Uncomment this two lines to enable log export
export PACKER_LOG=1
export PACKER_LOG_PATH="packerlog.txt"

packer build .
