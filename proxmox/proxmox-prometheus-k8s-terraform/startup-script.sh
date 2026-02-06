#!/bin/bash
# Start all Proxmox VMs

# VM IDs (from main.tf)
PROM1=2101
PROM2=2102
CONTROLLER=2120
WORKER1=2121
WORKER2=2122

echo "Starting VMs on Proxmox..."

# Note: I am using an SSH alias below to SSH into the remote Proxmox system and issue the QM commands.

ssh parallax "
qm start ${PROM1}
qm start ${PROM2}
sleep 10
qm start ${CONTROLLER}
sleep 20
qm start ${WORKER1}
qm start ${WORKER2}
"

echo "✅ VMs are starting"
echo "Wait 2-3 minutes for boot, then verify:"
echo "  ssh sa@10.42.88.120 'microk8s kubectl get nodes'"
