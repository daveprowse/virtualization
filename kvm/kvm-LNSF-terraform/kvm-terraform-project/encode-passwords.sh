#!/bin/bash

echo "========================================="
echo "  Password Encoder for KVM Infrastructure"
echo "  'Ni! Ni! Ni!'"
echo "========================================="
echo ""
echo "This script helps you encode passwords in Base64 for .env file"
echo "NOTE: Base64 is encoding (obfuscation), not encryption!"
echo ""

read -sp "Enter ROOT password: " root_pass
echo ""
read -sp "Enter USER password: " user_pass
echo ""
echo ""

echo "Add these to your .env file:"
echo "========================================="
echo "ROOT_PASSWORD_B64=\"$(echo -n "$root_pass" | base64)\""
echo "USER_PASSWORD_B64=\"$(echo -n "$user_pass" | base64)\""
echo "========================================="
echo ""
echo "To decode (for verification):"
echo "  echo \"EncodedString\" | base64 -d"
echo ""
echo "'Tis but an encoding!"
