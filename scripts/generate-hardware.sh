#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/templates/hardware.nix.template"

usage() {
    cat << EOF
Usage: $0 <hostname>

Arguments:
  hostname - Name of the host (required)

Examples:
  $0 myhost
EOF
    exit 1
}

# Pase arguments
if [[ $# -lt 1 ]]; then
    usage
fi

HOST_DIR="dendritic/hosts/nixos/${HOSTNAME}"
mkdir -p "$HOST_DIR"
HW_FILE="${HOST_DIR}/default.nix"

if [[ -f "$HW_FILE" ]]; then
    echo "Error: Hardware configuration already exists at $HW_FILE"
    exit 1
fi

# Generate the hardware configuration file from template
cp "$TEMPLATE_FILE" "$HW_FILE"

# Remove the first 3 comment lines and the surrounding braces (first 4 plus last)
HW_CONFIG=$(nixos-generate-config --show-hardware-config) | sed '1,4d;$d'

# Replace placeholders
sed -i "s|HOSTNAME_PLACEHOLDER|${HOSTNAME}|g" "$HW_FILE"
sed -i "s|HW_PLACEHOLDER|${HW_CONFIG}|g" $HW_FILE
nix fmt "$HW_FILE" -- --quiet
git add "$HW_FILE"

echo "✓ Created hardware configuration at $HW_FILE"
echo ""
echo "Next steps:"
echo "1. Edit your host file and add '(hardware hostname)' to your included aspects"
