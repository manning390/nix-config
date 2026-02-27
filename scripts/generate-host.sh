#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/templates/host.nix.template"

usage() {
    cat << EOF
Usage: $0 <hostname> [--type TYPE] [--aspects ASPECTS]

Arguments:
  hostname - Name of the host (required)
  --type TYPE - Host type 'nixos' or 'wsl' (default: nixos)
  --aspects ASPECTS - Comma-separated list of aspects (optional)

Examples:
  $0 myhost
  $0 myhost --type wsl
  $0 myhost --type nixos --aspects "wiki,git"
EOF
    exit 1
}

# Pase arguments
if [[ $# -lt 1 ]]; then
    usage
fi

HOSTNAME="$1"
shift

TYPE="nixos"
ASPECTS=""

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            TYPE="$2"
            shift 2
            ;;
        --aspects)
            ASPECTS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate type
if [[ "$TYPE" != "nixos" && "$TYPE" != "wsl" ]]; then
    echo "Error: type must be 'nixos' or 'wsl'"
    exit 1
fi

# Check template file
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file not found at $TEMPLATE_FILE"
    exit 1
fi

# Create host directory
HOST_DIR="dendritic/hosts/${TYPE}/${HOSTNAME}"
mkdir -p "$HOST_DIR"

HOST_FILE="${HOST_DIR}/default.nix"

if [[ -f "$HOST_FILE" ]]; then
    echo "Error: Host configuration already exists at $HOST_FILE"
    exit 1
fi

ASPECTS_LIST=""
if [[ -n "$ASPECTS" ]]; then
    IFS=',' read -ra ASPECT_ARRAY <<< "$ASPECTS"
    for aspect in "${ASPECT_ARRAY[@]}"; do
        ASPECTS_LIST="$NASPECTS_LIST\"${aspect}\" "
    done
fi


# Generate the host configuration file from template
cp "$TEMPLATE_FILE" "$HOST_FILE"

# Replace placeholders
sed -i "s|HOSTNAME_PLACEHOLDER|${HOSTNAME}|g" "$HOST_FILE"
sed -i "s|TYPE_PLACEHOLDER|${TYPE}|g" "$HOST_FILE"
sed -i "s|ASPECTS_PLACEHOLDER|${ASPECTS_LIST}|g" "$HOST_FILE"
nix fmt "$HOST_FILE" -- --quiet
git add "$HOST_FILE"

echo "✓ Created host configuration at $HOST_FILE"
echo ""
echo "Next steps:"
echo "1. Edit $HOST_FILE to customize your host configuration (update stateVersion)"
echo "2. Run 'just check' to verify the configuration"
echo "3. Build with 'just build'"
