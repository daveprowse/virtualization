#!/bin/bash
#
# cleanup-ssh-keys.sh
# Removes SSH host keys for VM IP addresses from known_hosts
# Run this before terraform apply to avoid "REMOTE HOST IDENTIFICATION HAS CHANGED" errors
#

set -e

# Source environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
else
    echo "Error: .env file not found at $PROJECT_ROOT/.env"
    exit 1
fi

# Define IP addresses from .env or use defaults
DEBSERVER_IP="${DEBSERVER_IP:-10.0.2.51}"
DEBCLIENT_IP="${DEBCLIENT_IP:-10.0.2.52}"
UBUNTU_SERVER_IP="${UBUNTU_SERVER_IP:-10.0.2.53}"
CENTOS_SERVER_IP="${CENTOS_SERVER_IP:-10.0.2.61}"
FEDORA_CLIENT_IP="${FEDORA_CLIENT_IP:-10.0.2.62}"
OPENSUSE_IP="${OPENSUSE_IP:-10.0.2.71}"

# Array of all IPs
IPS=(
    "$DEBSERVER_IP"
    "$DEBCLIENT_IP"
    "$UBUNTU_SERVER_IP"
    "$CENTOS_SERVER_IP"
    "$FEDORA_CLIENT_IP"
    "$OPENSUSE_IP"
)

echo "Cleaning up SSH host keys for VM IP addresses..."
echo "================================================"

# Check if known_hosts exists
if [ ! -f "$HOME/.ssh/known_hosts" ]; then
    echo "No known_hosts file found at $HOME/.ssh/known_hosts"
    echo "Nothing to clean up."
    exit 0
fi

# Remove each IP from known_hosts
for ip in "${IPS[@]}"; do
    echo -n "Removing $ip... "
    if ssh-keygen -R "$ip" >/dev/null 2>&1; then
        echo "✓ Removed"
    else
        echo "✓ Not found (OK)"
    fi
done

echo ""
echo "SSH cleanup complete!"
echo "You can now run 'terraform apply' without SSH host key conflicts."
