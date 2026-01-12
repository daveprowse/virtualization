# README

I use the scripts within to automatically create (or destroy) cloned virtual machines from golden images that I have already built and configured. I have not yet set up variables, so if you wish to run this you will need to make a bunch of changes!!!

> Note: Set the scripts to executable on your system and run the scripts with `sudo`.

The main script is called `clone-script.sh`. This does the following:

- Clone several golden images in KVM using the `virt-clone` command.
- Ping those systems with Ansible.
- Run an Ansible playbook against all systems which will update them automatically. (SSH keys have been copied over previously to the golden templates.)
- Shutdown all cloned VMs with the `virsh shutdown` command.

The Ansible playbook is run as root. While not normally recommended, I do this in my lab for speed. The VMs are temporary and do not store any sensitive information. 

To remove the VMs there is a script called `kill-script.sh`. This does the following:

- Uses the `virsh destroy` command to stop (destroy) all VMs (if they are running).
- Uses the `virsh undefine` command to delete the VMs with the `--wipe-storage` option so that the VM's storage drive is removed as well.
  
> **IMPORTANT!** As with any scripts, test them first, use them with care, and know what they will do before executing them!
