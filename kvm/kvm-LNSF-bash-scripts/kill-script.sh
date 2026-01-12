#!/bin/bash

# Set script to `chmod +x` and run with `sudo`

start=$SECONDS

echo
printf "\n\033[7;31mSTARTING KVM DESTROY PROCESS IN 5 SECONDS! \033[0m"
echo
sleep 5

virsh destroy LNSF-10.0.2.051-debian-13-server
virsh undefine LNSF-10.0.2.051-debian-13-server --wipe-storage --remove-all-storage

virsh destroy LNSF-10.0.2.052-debian-13-client 
virsh undefine LNSF-10.0.2.052-debian-13-client --wipe-storage --remove-all-storage

virsh destroy LNSF-10.0.2.053-ubuntu-24-server 
virsh undefine LNSF-10.0.2.053-ubuntu-24-server --wipe-storage --remove-all-storage

virsh destroy LNSF-10.0.2.061-centos-10-stream 
virsh undefine LNSF-10.0.2.061-centos-10-stream --wipe-storage --remove-all-storage

virsh destroy LNSF-10.0.2.062-fedora-ws-43
virsh undefine LNSF-10.0.2.062-fedora-ws-43 --wipe-storage --remove-all-storage

virsh destroy LNSF-10.0.2.071-opensuse-16
virsh undefine LNSF-10.0.2.071-opensuse-16 --wipe-storage --remove-all-storage

printf "\n\033[7;32mPROCESS COMPLETE! \033[0m"
echo
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
