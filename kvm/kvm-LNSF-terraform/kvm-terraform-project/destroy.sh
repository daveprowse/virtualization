#!/bin/bash
set -e

echo "========================================="
echo "  KVM Infrastructure Destruction Script"
echo "  'Run away! Run away!'"
echo "========================================="
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/terraform"

echo "WARNING: This will destroy all VMs!"
echo "Network and storage pool will be preserved."
echo "'Tis but a flesh wound!' ...said no VM ever."
echo ""
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Destruction cancelled. (Brave Sir Robin ran away!)"
    exit 0
fi

echo ""
echo "Destroying VMs with Terraform..."
terraform destroy -auto-approve

echo ""
echo "========================================="
echo "  All VMs destroyed!"
echo "  'None shall pass!' ...anymore."
echo "========================================="
