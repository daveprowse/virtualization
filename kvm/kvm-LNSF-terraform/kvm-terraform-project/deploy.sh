#!/bin/bash
set -e

# No one expects the Spanish Inquisition! But everyone expects working VMs...
echo "========================================"
echo "  KVM Infrastructure Deployment Script"
echo "  'Tis but a script!' - Black Knight"
echo "========================================"
echo ""

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if .env exists
if [ ! -f .env ]; then
    echo "ERROR: .env file not found!"
    echo "Please copy .env.example to .env and configure it."
    echo "(Run away! Run away!)"
    exit 1
fi

# Check .env permissions and set if needed
ENV_PERMS=$(stat -c "%a" .env 2>/dev/null || stat -f "%Lp" .env 2>/dev/null)
if [ "$ENV_PERMS" != "600" ] && [ "$ENV_PERMS" != "400" ]; then
    echo "WARNING: .env file has permissive permissions ($ENV_PERMS)"
    echo "Setting secure permissions (600)..."
    chmod 600 .env
fi

# Load environment variables
echo "[1/7] Loading configuration from .env..."
set -a
source .env
set +a

# Validate required variables
REQUIRED_VARS=(
    "SSH_PUBLIC_KEY_PATH"
    "ROOT_PASSWORD_B64"
    "USER_PASSWORD_B64"
    "KVM_IMAGES_DIR"
)

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: $var is not set in .env"
        echo "(What... is the air-speed velocity of an unladen swallow?)"
        exit 1
    fi
done

# Decode Base64 passwords
echo "[1.5/7] Decoding passwords... (Nobody expects the Base64 encoding!)"
ROOT_PASSWORD=$(echo "$ROOT_PASSWORD_B64" | base64 -d)
USER_PASSWORD=$(echo "$USER_PASSWORD_B64" | base64 -d)

if [ -z "$ROOT_PASSWORD" ] || [ -z "$USER_PASSWORD" ]; then
    echo "ERROR: Failed to decode passwords from Base64"
    echo "Please verify your Base64-encoded passwords in .env"
    exit 1
fi

# Expand home directory
KVM_IMAGES_DIR="${KVM_IMAGES_DIR/#\~/$HOME}"
KVM_IMAGES_DIR="${KVM_IMAGES_DIR/#\$HOME/$HOME}"
SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH/#\~/$HOME}"
SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH/#\$HOME/$HOME}"

# Read SSH public key
if [ ! -f "$SSH_PUBLIC_KEY_PATH" ]; then
    echo "ERROR: SSH public key not found at $SSH_PUBLIC_KEY_PATH"
    echo "(You've got no arms left!)"
    exit 1
fi

SSH_KEY=$(cat "$SSH_PUBLIC_KEY_PATH")

# Hash passwords for cloud-init
echo "[2/7] Hashing passwords... (Not the comfy chair!)"
ROOT_PASSWORD_HASH=$(python3 -c "import crypt; print(crypt.crypt('$ROOT_PASSWORD', crypt.mksalt(crypt.METHOD_SHA512)))")
USER_PASSWORD_HASH=$(python3 -c "import crypt; print(crypt.crypt('$USER_PASSWORD', crypt.mksalt(crypt.METHOD_SHA512)))")

# Create KVM images directory
echo "[3/7] Creating KVM images directory..."
mkdir -p "$KVM_IMAGES_DIR"
chmod 755 "$KVM_IMAGES_DIR"

# Verify network exists
echo "[3.5/7] Verifying KVM network exists... (Checking for the Bridge of Death!)"
if ! sudo virsh net-list --all | grep -q "$NETWORK_NAME"; then
    echo "ERROR: Network '$NETWORK_NAME' does not exist!"
    echo "Please create the network first. Expected subnet: $NETWORK_SUBNET"
    echo "(You shall not pass... without the network!)"
    exit 1
fi

if ! sudo virsh net-list | grep -q "$NETWORK_NAME.*active"; then
    echo "WARNING: Network '$NETWORK_NAME' exists but is not active."
    echo "Attempting to start network..."
    sudo virsh net-start "$NETWORK_NAME" || {
        echo "ERROR: Failed to start network '$NETWORK_NAME'"
        exit 1
    }
fi
echo "  ✓ Network '$NETWORK_NAME' is active"

# Download cloud images
echo "[4/7] Downloading cloud images... (Fetching the holy images!)"

download_if_missing() {
    local url=$1
    local filename=$2
    local filepath="$KVM_IMAGES_DIR/$filename"
    
    if [ -f "$filepath" ]; then
        echo "  ✓ $filename already exists"
        return 0
    fi
    
    echo "  → Downloading $filename..."
    
    # Try wget first
    if wget --show-progress -O "$filepath" "$url" 2>&1; then
        if [ -f "$filepath" ] && [ -s "$filepath" ]; then
            echo "  ✓ Downloaded $filename"
            return 0
        fi
    fi
    
    # If wget failed, try curl
    echo "  → wget failed, trying curl..."
    if curl -L --progress-bar -o "$filepath" "$url"; then
        if [ -f "$filepath" ] && [ -s "$filepath" ]; then
            echo "  ✓ Downloaded $filename with curl"
            return 0
        fi
    fi
    
    # Both failed
    echo "ERROR: Failed to download $filename"
    echo "URL: $url"
    echo "(We've already got one... NOT!)"
    rm -f "$filepath"  # Remove partial download
    return 1
}

# Debian 13
download_if_missing "$DEBIAN_IMAGE_URL" "$DEBIAN_IMAGE_NAME"

# Ubuntu 24.04
download_if_missing "$UBUNTU_IMAGE_URL" "$UBUNTU_IMAGE_NAME"

# CentOS Stream 10
download_if_missing "$CENTOS_IMAGE_URL" "$CENTOS_IMAGE_NAME"

# Fedora 41
download_if_missing "$FEDORA_IMAGE_URL" "$FEDORA_IMAGE_NAME"

# OpenSUSE Leap 15.6
download_if_missing "$OPENSUSE_IMAGE_URL" "$OPENSUSE_IMAGE_NAME"

# Initialize Terraform
echo "[5/7] Initializing Terraform... (We are the Knights who say... INIT!)"
cd terraform
if [ ! -d ".terraform" ]; then
    terraform init
fi

# Create terraform.tfvars
cat > terraform.tfvars <<EOF
ssh_public_key = "$SSH_KEY"
root_password = "$ROOT_PASSWORD_HASH"
user_password = "$USER_PASSWORD_HASH"
kvm_images_dir = "$KVM_IMAGES_DIR"
debian_image_name = "$DEBIAN_IMAGE_NAME"
ubuntu_image_name = "$UBUNTU_IMAGE_NAME"
centos_image_name = "$CENTOS_IMAGE_NAME"
fedora_image_name = "$FEDORA_IMAGE_NAME"
opensuse_image_name = "$OPENSUSE_IMAGE_NAME"
network_name = "$NETWORK_NAME"
debserver_hostname = "$DEBSERVER_HOSTNAME"
debserver_ip = "$DEBSERVER_IP"
debclient_hostname = "$DEBCLIENT_HOSTNAME"
debclient_ip = "$DEBCLIENT_IP"
ubuntu_server_hostname = "$UBUNTU_SERVER_HOSTNAME"
ubuntu_server_ip = "$UBUNTU_SERVER_IP"
centos_server_hostname = "$CENTOS_SERVER_HOSTNAME"
centos_server_ip = "$CENTOS_SERVER_IP"
fedora_client_hostname = "$FEDORA_CLIENT_HOSTNAME"
fedora_client_ip = "$FEDORA_CLIENT_IP"
opensuse_hostname = "$OPENSUSE_HOSTNAME"
opensuse_ip = "$OPENSUSE_IP"
EOF

# Deploy VMs with Terraform
echo "[6/7] Deploying VMs with Terraform... (Bring out yer dead VMs!)"
terraform plan
terraform apply -auto-approve

cd ..

# Wait for VMs to be ready
echo ""
echo "Waiting for VMs to boot and complete cloud-init..."
echo "(On second thought, let's not go to Camelot. 'Tis a silly place.)"
sleep 60

# Run Ansible configuration
echo "[7/7] Running Ansible configuration... (And now for something completely different!)"
cd ansible

# Test connectivity first
echo "Testing SSH connectivity..."
for i in {1..5}; do
    ansible all -i inventory.ini -m ping --ssh-extra-args="-o ConnectTimeout=5" && break
    echo "Attempt $i failed, retrying in 10 seconds..."
    sleep 10
done

# Run the configuration playbook
ansible-playbook -i inventory.ini configure.yml

cd ..

echo ""
echo "========================================"
echo "  Deployment Complete!"
echo "  'We are the knights who say... SSH!'"
echo "========================================"
echo ""
echo "VM Information:"
echo "  Debian Server:   ssh root@$DEBSERVER_IP or ssh user@$DEBSERVER_IP (user is standard)"
echo "  Debian Client:   ssh root@$DEBCLIENT_IP or ssh user@$DEBCLIENT_IP"
echo "  Ubuntu Server:   ssh root@$UBUNTU_SERVER_IP or ssh user@$UBUNTU_SERVER_IP"
echo "  CentOS Server:   ssh root@$CENTOS_SERVER_IP or ssh user@$CENTOS_SERVER_IP"
echo "  Fedora Client:   ssh root@$FEDORA_CLIENT_IP or ssh user@$FEDORA_CLIENT_IP"
echo "  OpenSUSE:        ssh root@$OPENSUSE_IP or ssh user@$OPENSUSE_IP"
echo ""
echo "Note: Some configurations (GUI settings) may require a reboot to take full effect."
echo "'Tis but a reboot!"
