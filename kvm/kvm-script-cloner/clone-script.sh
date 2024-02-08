#!/bin/bash

# Set script to `chmod +x` and run with `sudo`

start=$SECONDS

echo
printf "\n\033[7;32mSTARTING KVM BUILD PROCESS IN 5 SECONDS! \033[0m"
echo
sleep 5
echo

virt-clone -o template-debian-12-server -n LNSF-10.0.2.051-debian-12-server -f /mnt/nvme/KVM/LNSF-10.0.2.051-debian-12-server.qcow 
virsh start LNSF-10.0.2.051-debian-12-server 

virt-clone -o template-debian12-client -n LNSF-10.0.2.052-debian-12-client -f /mnt/nvme/KVM/LNSF-10.0.2.052-debian-12-client.qcow
virsh start LNSF-10.0.2.052-debian-12-client 

virt-clone -o template-ubuntu-22.04-server -n LNSF-10.0.2.053-ubuntu-22-04-server -f /mnt/nvme/KVM/LNSF-10.0.2.053-ubuntu-22-04-server.qcow
virsh start LNSF-10.0.2.053-ubuntu-22-04-server 

virt-clone -o template-centos-9-stream -n LNSF-10.0.2.061-centos-9-stream -f /mnt/nvme/KVM/LNSF-10.0.2.061-centos-9-stream.qcow
virsh start LNSF-10.0.2.061-centos-9-stream     

virt-clone -o template-fedora-ws-39 -n LNSF-10.0.2.062-fedora-ws-39 -f /mnt/nvme/KVM/LNSF-10.0.2.062-fedora-39-ws.qcow
virsh start LNSF-10.0.2.062-fedora-ws-39 

virt-clone -o template-opensuse-15.4 -n LNSF-10.0.2.071-opensuse-15-4 -f /mnt/nvme/KVM/LNSF-10.0.2.071-opensuse-15-4.qcow
virsh start LNSF-10.0.2.071-opensuse-15-4 

echo
printf "\n\033[7;32mALL VIRTUAL MACHINES ARE BUILT! \033[0m"
echo
echo
sleep 1

printf "\n\033[7;31mWAITING 30 SECONDS FOR SYSTEMS TO INITIALIZE - PING CHECK......\033[0m\n\n"
sleep 30

ansible all --private-key ../keys/kvm_key -i inventory -u root -m ping

printf "\n\033[7;31mWAITING 5 SECONDS BEFORE RUNNING THE PLAYBOOK......\033[0m\n\n"
sleep 5

ansible-playbook playbook.yml --private-key ../keys/kvm_key -i inventory -u root

printf "\n\033[7;31mWAITING 5 SECONDS BEFORE INITIATING SHUTDOWN OF VMS......\033[0m\n\n"
sleep 5

virsh shutdown LNSF-10.0.2.051-debian-12-server 
virsh shutdown LNSF-10.0.2.052-debian-12-client 
virsh shutdown LNSF-10.0.2.053-ubuntu-22-04-server 
virsh shutdown LNSF-10.0.2.061-centos-9-stream     
virsh shutdown LNSF-10.0.2.062-fedora-ws-39 
virsh shutdown LNSF-10.0.2.071-opensuse-15-4 


printf "\n\033[7;32mPROCESS COMPLETE! \033[0m"
echo
printf "\nTime to complete = %s seconds" "$SECONDS"
echo

