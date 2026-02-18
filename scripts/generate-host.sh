#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/templates/host.nix.template"

usage() {
    cat << EOF
Usage: $0 <hostname> [type] [aspects]

Arguments:
  hostname - Name of the host (required)
  type - Host type 'nixos' or 'wsl' (default: nixos)
  aspects - Comma-separated list of aspects (optional)

Examples:
  $0 myhost
  $0 myhost wsl
  $0 myhost nixos "wiki,git"
EOF
    exit 1
}

# Pase arguments
if [[ $# -lt 1 ]]; then
    usage
fi

HOSTNAME="$1"
TYPE="${2:-nixos}"
ASPECTS="${3:-}"

if [[ "$TYPE" != "nixos" && "$TYPE" != "wsl" ]]; then
    echo "Error: type must be 'nixos' or 'wsl'"
    exit 1
fi

# Create host directory
HOST_DIR="dendritic/hosts/${TYPE}"
mkdir -p "$HOST_DIR"

HOST_FILE="${HOST_DIR}/${HOSTNAME}.nix"

if [[ -f "$HOST_FILE" ]]; then
    echo "Error: HOst configuration already exists at $HOST_FILE"
    exit 1
fi

ASPECTS_LIST=""
if [[ -n "$ASPECTS" ]]; then
    IFS=',' read -ra ASPECT_ARRAY <<< "$ASPECTS"
    for aspect in "${ASPECT_ARRAY[@]}"; do
        ASPECTS_LIST="$NASPECTS_LIST\"${aspect}\" "
    done
fi

LOCAL_CONFIG=""
MODULES=""
if [[ "$TYPE" == "WSL" ]]; then
    MODULES='../../modules/wsl'
    LOCAL_CONFIG='wsl.enable = true;'
fi

# Generate the host configuration file from template
cp "$TEMPLATE_FILE" "$HOST_FILE"

# Replace placeholders
sed -i "s|HOSTNAME_PLACEHOLDER|${HOSTNAME}|g" "$HOST_FILE"
sed -i "s|TYPE_PLACEHOLDER|${TYPE}|g" "$HOST_FILE"
sed -i "s|ASPECTS_PLACEHOLDER|${ASPECTS_LIST}|g" "$HOST_FILE"
sed -i "/MODULES_PLACEHOLDER/c\\${MODULES}" "$HOST_FILE"
sed -i "/LOCAL_CONFIG_PLACEHOLDER/c\\${LOCAL_CONFIG}" "$HOST_FILE"
nix fmt "$HOST_FILE" --quiet

echo "✓ Created host configuration at $HOST_FILE"
echo ""
echo "Next steps:"
echo "1. Edit $HOST_FILE to customize your host configuration"
echo "2. Git add $HOST_FILE so the config sees it"
echo "3. Run 'just check' to verify the configuration"
echo "4. Build with 'just build'"
