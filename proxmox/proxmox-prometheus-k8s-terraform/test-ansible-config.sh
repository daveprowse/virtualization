#!/bin/bash
# Test Ansible Configuration
# Verifies SSH key and inventory are configured correctly

echo "Testing Ansible Configuration..."
echo "================================================"
echo ""

cd ansible

echo "1. Checking SSH key configuration..."
echo "-----------------------------------"

# Get the SSH key path from a specific host (which will have variables expanded)
KEY_PATH=$(ansible-inventory --host controller -i inventory.yml 2>/dev/null | grep -o '"ansible_ssh_private_key_file": "[^"]*"' | cut -d'"' -f4)

if [ -z "$KEY_PATH" ]; then
    echo "❌ Could not determine SSH key path from inventory"
    echo "Trying to read from group_vars..."
    
    # Fallback: read directly from group_vars
    if [ -f "group_vars/all.yml" ]; then
        SSH_KEY_NAME=$(grep "ssh_key_name:" group_vars/all.yml | awk '{print $2}' | tr -d '"' | tr -d "'")
        if [ -n "$SSH_KEY_NAME" ]; then
            KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"
            echo "Found in group_vars: ssh_key_name = $SSH_KEY_NAME"
        fi
    fi
fi

if [ -z "$KEY_PATH" ]; then
    echo "❌ Could not determine SSH key path"
    exit 1
fi

echo "Ansible will use SSH key: $KEY_PATH"

# Expand tilde if present
KEY_PATH_EXPANDED="${KEY_PATH/#\~/$HOME}"

if [ -f "$KEY_PATH_EXPANDED" ]; then
    echo "✅ SSH key exists"
    
    # Check key permissions
    PERMS=$(stat -c "%a" "$KEY_PATH_EXPANDED" 2>/dev/null || stat -f "%A" "$KEY_PATH_EXPANDED" 2>/dev/null)
    if [ "$PERMS" = "600" ] || [ "$PERMS" = "400" ]; then
        echo "✅ SSH key has correct permissions ($PERMS)"
    else
        echo "⚠️  SSH key permissions are $PERMS (should be 600 or 400)"
        echo "   Run: chmod 600 $KEY_PATH_EXPANDED"
    fi
else
    echo "❌ SSH key not found: $KEY_PATH_EXPANDED"
    echo ""
    echo "To fix:"
    echo "  1. Copy your key: cp /path/to/your/key $KEY_PATH_EXPANDED"
    echo "  2. Or edit ansible/group_vars/all.yml to change ssh_key_name"
    exit 1
fi

echo ""
echo "2. Checking inventory configuration..."
echo "--------------------------------------"

# List all hosts
echo "Hosts in inventory:"
ansible all -i inventory.yml --list-hosts 2>/dev/null | grep -v "hosts (" | sed 's/^/  ✅ /'

echo ""
echo "3. Testing group configuration..."
echo "---------------------------------"

# Check groups
echo "Groups defined:"
ansible-inventory --graph -i inventory.yml 2>/dev/null

echo ""
echo "4. Verifying MicroK8s cluster composition..."
echo "--------------------------------------------"

CONTROLLER_COUNT=$(ansible microk8s_controller -i inventory.yml --list-hosts 2>/dev/null | grep -v "hosts (" | wc -l)
WORKER_COUNT=$(ansible microk8s_workers -i inventory.yml --list-hosts 2>/dev/null | grep -v "hosts (" | wc -l)
TOTAL_K8S=$((CONTROLLER_COUNT + WORKER_COUNT))

echo "MicroK8s nodes:"
echo "  Controllers: $CONTROLLER_COUNT"
echo "  Workers: $WORKER_COUNT"
echo "  Total: $TOTAL_K8S"

if [ "$CONTROLLER_COUNT" -lt 1 ]; then
    echo "❌ No controller found"
    exit 1
fi

if [ "$WORKER_COUNT" -lt 1 ]; then
    echo "⚠️  No workers found (you need at least 1 worker)"
fi

echo ""
echo "5. Quick connectivity test..."
echo "-----------------------------"

# Only test if VMs exist
if ping -c 1 -W 1 10.42.88.120 &>/dev/null; then
    echo "Testing SSH connectivity to existing VMs..."
    ./test-connectivity.sh
else
    echo "⚠️  VMs not deployed yet (this is OK for first run)"
    echo "   Connectivity will be tested during deployment"
fi

cd ..

echo ""
echo "================================================"
echo "✅ Ansible configuration is valid!"
echo ""
echo "SSH Key: $KEY_PATH_EXPANDED"
echo "MicroK8s Cluster: $TOTAL_K8S nodes ($CONTROLLER_COUNT controller + $WORKER_COUNT workers)"
echo ""
echo "Ready to deploy: ./deploy.sh"
