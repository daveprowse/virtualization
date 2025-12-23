#!/bin/bash
# Script to destroy all infrastructure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "KVM Infrastructure Destruction"
echo "=========================================="
echo ""
echo "WARNING: This will destroy all VMs and volumes!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Destroying infrastructure..."
terraform destroy

echo ""
echo "Infrastructure destroyed successfully!"
