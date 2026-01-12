#!/bin/bash

# Set script to `chmod +x` and run with `sudo`

start=$SECONDS

echo
printf "\n\033[7;32mSTARTING KVM BUILD PROCESS IN 5 SECONDS! \033[0m"
echo
sleep 5
echo

virt-clone -o template-debian-13-server -n LNSF-10.0.2.051-debian-13-server -f /home/dpro/VMs/LNSF-10.0.2.051-debian-13-server.qcow 
virsh start LNSF-10.0.2.051-debian-13-server 

virt-clone -o template-debian-13-client -n LNSF-10.0.2.052-debian-13-client -f /home/dpro/VMs/LNSF-10.0.2.052-debian-13-client.qcow
virsh start LNSF-10.0.2.052-debian-13-client 

virt-clone -o template-ubuntu-24-server -n LNSF-10.0.2.053-ubuntu-24-server -f /home/dpro/VMs/LNSF-10.0.2.053-ubuntu-24-server.qcow
virsh start LNSF-10.0.2.053-ubuntu-24-server 

# virt-clone -o template-ubuntu-22.04-server -n LNSF-10.0.2.053-ubuntu-22-04-server -f /mnt/nvme/KVM/LNSF-10.0.2.053-ubuntu-22-04-server.qcow
# virsh start LNSF-10.0.2.053-ubuntu-22-04-server 

virt-clone -o template-centos-10-stream -n LNSF-10.0.2.061-centos-10-stream -f /home/dpro/VMs/LNSF-10.0.2.061-centos-10-stream.qcow
virsh start LNSF-10.0.2.061-centos-10-stream     

## Cloning from the Fedora Tester (which I update often due to D.O.G. testing)
virt-clone -o D.O.G.-Fedora-tester-GNOME-49 -n LNSF-10.0.2.062-fedora-ws-43 -f /home/dpro/VMs/LNSF-10.0.2.062-fedora-43-ws.qcow
virsh start LNSF-10.0.2.062-fedora-ws-43 

virt-clone -o template-opensuse-16 -n LNSF-10.0.2.071-opensuse-16 -f /home/dpro/VMs/LNSF-10.0.2.071-opensuse-16.qcow
virsh start LNSF-10.0.2.071-opensuse-16 

echo
printf "\n\033[7;32mALL VIRTUAL MACHINES ARE BUILT! \033[0m"
echo
echo
sleep 1

printf "\n\033[7;31mWAITING 30 SECONDS FOR SYSTEMS TO INITIALIZE - PING CHECK......\033[0m\n\n"
sleep 30

ansible all --private-key /home/dpro/.ssh/lnsf-ed25519 -i inventory -u root -m ping

printf "\n\033[7;31mWAITING 5 SECONDS BEFORE RUNNING THE PLAYBOOK......\033[0m\n\n"
sleep 5

# added -vvv for verbose mode
ansible-playbook playbook.yml -vvv --private-key  /home/dpro/.ssh/lnsf-ed25519 -i inventory -u root

printf "\n\033[7;31mWAITING 5 SECONDS BEFORE INITIATING SHUTDOWN OF VMS......\033[0m\n\n"
sleep 5

virsh shutdown LNSF-10.0.2.051-debian-13-server 
virsh shutdown LNSF-10.0.2.052-debian-13-client 
virsh shutdown LNSF-10.0.2.053-ubuntu-24-server 
virsh shutdown LNSF-10.0.2.061-centos-10-stream     
virsh shutdown LNSF-10.0.2.062-fedora-ws-43
virsh shutdown LNSF-10.0.2.071-opensuse-16 


printf "\n\033[7;32mPROCESS COMPLETE! \033[0m"
echo
printf "\nTime to complete = %s seconds" "$SECONDS"
echo

