#!/bin/bash
# Script to generate password hashes for cloud-init

echo "Password Hash Generator for Cloud-Init"
echo "======================================="
echo ""
echo "Enter password to hash:"
read -s PASSWORD

# Generate SHA-512 hash
HASH=$(python3 -c "import crypt; print(crypt.crypt('$PASSWORD', crypt.mksalt(crypt.METHOD_SHA512)))")

echo ""
echo "Hashed password:"
echo "$HASH"
echo ""
echo "Add this to your terraform.tfvars file"
