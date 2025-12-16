# Project Configuration
# Source this file in scripts: source "$(dirname "$0")/config.sh"

# Load .env file (single source of truth)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/.env" ]; then
    source "${SCRIPT_DIR}/.env"
else
    echo "⚠️  Warning: .env file not found!"
    echo "   Please create .env file with your SSH_KEY_NAME"
    echo "   See .env.example for template"
    # Set defaults
    SSH_KEY_NAME="${SSH_KEY_NAME:-proxmox_key}"
fi

# Construct full SSH key path
SSH_KEY_PATH="$HOME/.ssh/${SSH_KEY_NAME}"

# Verify SSH key exists
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "⚠️  SSH key not found: $SSH_KEY_PATH"
    echo "   Please either:"
    echo "   1. Create/copy your SSH key to: $SSH_KEY_PATH"
    echo "   2. Edit .env and change SSH_KEY_NAME"
fi

# SSH options for automation
SSH_KEY_OPT="-i $SSH_KEY_PATH"
SSH_OPTS="$SSH_KEY_OPT -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

# VM Configuration (from .env)
VM_USER="${VM_USER:-sa}"
VM_IPS=(
    "${VM_IP_PROM1:-10.42.88.1}"
    "${VM_IP_PROM2:-10.42.88.2}"
    "${VM_IP_CONTROLLER:-10.42.88.120}"
    "${VM_IP_WORKER1:-10.42.88.121}"
    "${VM_IP_WORKER2:-10.42.88.122}"
)

# Logging
LOG_DIR="${LOG_DIR:-./logs}"
