output "controller_ip" {
  description = "IP address of the controller node"
  value       = proxmox_virtual_environment_vm.controller.initialization[0].ip_config[0].ipv4[0].address
}

output "controller_vmid" {
  description = "VMID of the controller"
  value       = proxmox_virtual_environment_vm.controller.vm_id
}

output "worker1_ip" {
  description = "IP address of worker1"
  value       = proxmox_virtual_environment_vm.worker1.initialization[0].ip_config[0].ipv4[0].address
}

output "worker1_vmid" {
  description = "VMID of worker1"
  value       = proxmox_virtual_environment_vm.worker1.vm_id
}

output "worker2_ip" {
  description = "IP address of worker2"
  value       = proxmox_virtual_environment_vm.worker2.initialization[0].ip_config[0].ipv4[0].address
}

output "worker2_vmid" {
  description = "VMID of worker2"
  value       = proxmox_virtual_environment_vm.worker2.vm_id
}

output "prom1_ip" {
  description = "IP address of prom1"
  value       = proxmox_virtual_environment_vm.prom1.initialization[0].ip_config[0].ipv4[0].address
}

output "prom1_vmid" {
  description = "VMID of prom1"
  value       = proxmox_virtual_environment_vm.prom1.vm_id
}

output "prom2_ip" {
  description = "IP address of prom2"
  value       = proxmox_virtual_environment_vm.prom2.initialization[0].ip_config[0].ipv4[0].address
}

output "prom2_vmid" {
  description = "VMID of prom2"
  value       = proxmox_virtual_environment_vm.prom2.vm_id
}

output "cluster_info" {
  description = "Information about the deployed infrastructure"
  value       = <<-EOT
    
═══════════════════════════════════════════════════════════════════════
Infrastructure Deployed Successfully!
═══════════════════════════════════════════════════════════════════════
    
STANDALONE SERVERS:
├─ prom1: ${split("/", proxmox_virtual_environment_vm.prom1.initialization[0].ip_config[0].ipv4[0].address)[0]} (VMID: ${proxmox_virtual_environment_vm.prom1.vm_id})
└─ prom2: ${split("/", proxmox_virtual_environment_vm.prom2.initialization[0].ip_config[0].ipv4[0].address)[0]} (VMID: ${proxmox_virtual_environment_vm.prom2.vm_id})
    
MICROK8S CLUSTER NODES:
├─ Controller: ${split("/", proxmox_virtual_environment_vm.controller.initialization[0].ip_config[0].ipv4[0].address)[0]} (VMID: ${proxmox_virtual_environment_vm.controller.vm_id})
├─ Worker 1:   ${split("/", proxmox_virtual_environment_vm.worker1.initialization[0].ip_config[0].ipv4[0].address)[0]} (VMID: ${proxmox_virtual_environment_vm.worker1.vm_id})
└─ Worker 2:   ${split("/", proxmox_virtual_environment_vm.worker2.initialization[0].ip_config[0].ipv4[0].address)[0]} (VMID: ${proxmox_virtual_environment_vm.worker2.vm_id})
    
NEXT STEPS:
    
1. Wait 2-3 minutes for cloud-init to complete on all VMs
    
2. Test SSH connectivity:
   cd ansible
   ./test-connectivity.sh
    
3. Install MicroK8s on cluster nodes:
   ansible-playbook microk8s-cluster.yml
   (This installs MicroK8s ONLY on controller and workers, NOT on prom1/prom2)
    
TO ACCESS STANDALONE SERVERS:
   ssh sa@${split("/", proxmox_virtual_environment_vm.prom1.initialization[0].ip_config[0].ipv4[0].address)[0]}  # prom1
   ssh sa@${split("/", proxmox_virtual_environment_vm.prom2.initialization[0].ip_config[0].ipv4[0].address)[0]}  # prom2
    
TO ACCESS MICROK8S CLUSTER:
    
1. SSH to controller:
   ssh sa@${split("/", proxmox_virtual_environment_vm.controller.initialization[0].ip_config[0].ipv4[0].address)[0]}
    
2. View cluster status:
   microk8s status
   microk8s kubectl get nodes
    
3. View all pods:
   microk8s kubectl get pods --all-namespaces
    
4. Access Dashboard:
   See DASHBOARD-ACCESS.md for complete instructions
    
5. Get kubeconfig for local kubectl:
   microk8s config > kubeconfig
   # Then copy to your local machine
    
ENABLED SERVICES (on MicroK8s cluster):
├─ Dashboard: Kubernetes Dashboard UI
├─ DNS:       CoreDNS for cluster DNS
└─ Registry:  Local container registry (localhost:32000)
    
═══════════════════════════════════════════════════════════════════════
    
EOT
}
