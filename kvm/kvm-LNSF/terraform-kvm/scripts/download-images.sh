#!/bin/bash
# Download cloud images as the current user to avoid root ownership issues

set -e

IMAGES_DIR="$HOME/kvm-images"
mkdir -p "$IMAGES_DIR"

echo "Downloading cloud images to $IMAGES_DIR..."
echo "This may take 10-15 minutes depending on your connection."
echo ""

# Debian 13
if [ ! -f "$IMAGES_DIR/debian-13-generic-amd64.qcow2" ]; then
    echo "Downloading Debian 13..."
    wget -q --show-progress -O "$IMAGES_DIR/debian-13-generic-amd64.qcow2" \
        "http://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
else
    echo "Debian 13 already downloaded"
fi

# Ubuntu 24.04
if [ ! -f "$IMAGES_DIR/ubuntu-24.04-server-cloudimg-amd64.img" ]; then
    echo "Downloading Ubuntu 24.04..."
    wget -q --show-progress -O "$IMAGES_DIR/ubuntu-24.04-server-cloudimg-amd64.img" \
        "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
else
    echo "Ubuntu 24.04 already downloaded"
fi

# CentOS Stream 10
if [ ! -f "$IMAGES_DIR/centos-stream-10-genericcloud.qcow2" ]; then
    echo "Downloading CentOS Stream 10..."
    wget -q --show-progress -O "$IMAGES_DIR/centos-stream-10-genericcloud.qcow2" \
        "https://cloud.centos.org/centos/10-stream/x86_64/images/CentOS-Stream-GenericCloud-10-latest.x86_64.qcow2"
else
    echo "CentOS Stream 10 already downloaded"
fi

# Fedora 41
if [ ! -f "$IMAGES_DIR/fedora-41-cloud-base.qcow2" ]; then
    echo "Downloading Fedora 41..."
    wget -q --show-progress -O "$IMAGES_DIR/fedora-41-cloud-base.qcow2" \
        "https://download.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2"
else
    echo "Fedora 41 already downloaded"
fi

# OpenSUSE Leap 15.6
if [ ! -f "$IMAGES_DIR/opensuse-leap-15.6-nocloud.qcow2" ]; then
    echo "Downloading OpenSUSE Leap 15.6..."
    wget -q --show-progress -O "$IMAGES_DIR/opensuse-leap-15.6-nocloud.qcow2" \
        "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.6/images/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2"
else
    echo "OpenSUSE Leap 15.6 already downloaded"
fi

echo ""
echo "All images downloaded successfully!"
echo "Images location: $IMAGES_DIR"
echo ""
echo "You can now run: terraform apply"
