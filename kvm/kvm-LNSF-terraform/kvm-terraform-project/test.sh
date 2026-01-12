#!/bin/bash

echo "================================================"
echo "  VM Infrastructure Test Script"
echo "  'What... is your favorite testing method?'"
echo "================================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load environment
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "ERROR: .env file not found!"
    exit 1
fi

set -a
source "$SCRIPT_DIR/.env"
set +a

test_ssh() {
    local name=$1
    local ip=$2
    local user=$3
    
    echo "Testing $name ($ip) as $user..."
    
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${user}@${ip}" "echo 'SSH OK' && hostname && uname -a" 2>/dev/null; then
        echo "  ✓ SSH connection successful"
        return 0
    else
        echo "  ✗ SSH connection failed"
        return 1
    fi
}

test_user_exists() {
    local name=$1
    local ip=$2
    local user=$3
    local test_user=$4
    
    echo "Checking if user '$test_user' exists on $name..."
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${user}@${ip}" "id $test_user" 2>/dev/null; then
        echo "  ✓ User $test_user exists"
        return 0
    else
        echo "  ✗ User $test_user not found"
        return 1
    fi
}

test_package() {
    local name=$1
    local ip=$2
    local user=$3
    local package=$4
    local command=$5
    
    echo "Testing if $package is installed on $name..."
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${user}@${ip}" "which $command" 2>/dev/null; then
        echo "  ✓ $package is installed"
        return 0
    else
        echo "  ✗ $package not found"
        return 1
    fi
}

echo "=== Testing Debian Server ==="
test_ssh "debserver" "$DEBSERVER_IP" "root"
test_user_exists "debserver" "$DEBSERVER_IP" "root" "user"
test_package "debserver" "$DEBSERVER_IP" "root" "VIM" "vim"
test_package "debserver" "$DEBSERVER_IP" "root" "TMUX" "tmux"
echo ""

echo "=== Testing Debian Client ==="
test_ssh "debclient" "$DEBCLIENT_IP" "user"
test_package "debclient" "$DEBCLIENT_IP" "user" "VIM" "vim"
test_package "debclient" "$DEBCLIENT_IP" "user" "TMUX" "tmux"
test_package "debclient" "$DEBCLIENT_IP" "user" "Tilix" "tilix"
echo ""

echo "=== Testing Ubuntu Server ==="
test_ssh "ubuntu-server" "$UBUNTU_SERVER_IP" "user"
test_package "ubuntu-server" "$UBUNTU_SERVER_IP" "user" "VIM" "vim"
test_package "ubuntu-server" "$UBUNTU_SERVER_IP" "user" "TMUX" "tmux"
echo ""

echo "=== Testing CentOS Server ==="
test_ssh "centos-server" "$CENTOS_SERVER_IP" "user"
test_package "centos-server" "$CENTOS_SERVER_IP" "user" "VIM" "vim"
test_package "centos-server" "$CENTOS_SERVER_IP" "user" "TMUX" "tmux"
echo ""

echo "=== Testing Fedora Client ==="
test_ssh "fed-client" "$FEDORA_CLIENT_IP" "user"
test_package "fed-client" "$FEDORA_CLIENT_IP" "user" "VIM" "vim"
test_package "fed-client" "$FEDORA_CLIENT_IP" "user" "TMUX" "tmux"
test_package "fed-client" "$FEDORA_CLIENT_IP" "user" "Tilix" "tilix"
echo ""

echo "=== Testing OpenSUSE ==="
test_ssh "opensuse" "$OPENSUSE_IP" "user"
test_package "opensuse" "$OPENSUSE_IP" "user" "VIM" "vim"
test_package "opensuse" "$OPENSUSE_IP" "user" "TMUX" "tmux"
echo ""

echo "================================================"
echo "  Test complete!"
echo "  'Right! We'll call it a draw.'"
echo "================================================"
