#!/bin/bash
# Stop all Proxmox VMs

# VM IDs (from main.tf)
PROM1=2101
PROM2=2102
CONTROLLER=2120
WORKER1=2121
WORKER2=2122

echo "Stopping VMs on Proxmox..."

# Note: I am using an SSH alias below to SSH into the remote Proxmox system and issue the QM commands.

ssh parallax "
qm shutdown ${WORKER2}
qm shutdown ${WORKER1}
qm shutdown ${CONTROLLER}
qm shutdown ${PROM2}
qm shutdown ${PROM1}
"

echo "✅ Shutdown commands sent"
echo "VMs will power down gracefully (takes ~30 seconds)"