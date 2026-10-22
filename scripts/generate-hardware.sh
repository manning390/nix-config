#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/templates/hardware.nix.template"

usage() {
    cat << EOF
Usage: $0 <hostname> [--root ROOT] [--no-filesystems] [--input FILE]

Arguments:
  hostname - Name of the host (required)
  --root ROOT - Root filesystem to scan (use / for the live installer, /mnt for a mounted target)
  --no-filesystems - Omit filesystem and swap entries (for Disko-managed hosts)
  --input FILE - Use hardware config captured on the target machine

Examples:
  $0 myhost --root / --no-filesystems
  $0 myhost --root /mnt
  $0 myhost --root /mnt --no-filesystems
  $0 myhost --input /tmp/myhost-hardware.nix
EOF
    exit 1
}

# Parse arguments
if [[ $# -lt 1 ]]; then
    usage
fi

HOSTNAME="$1"
shift

GENERATOR_ARGS=()
INPUT_FILE=""
ROOT_SPECIFIED=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root)
            if [[ $# -lt 2 ]]; then usage; fi
            GENERATOR_ARGS+=(--root "$2")
            ROOT_SPECIFIED=true
            shift 2
            ;;
        --no-filesystems)
            GENERATOR_ARGS+=(--no-filesystems)
            shift
            ;;
        --input)
            if [[ $# -lt 2 ]]; then usage; fi
            INPUT_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

HOST_DIR="dendritic/hosts/nixos/${HOSTNAME}"
HW_FILE="${HOST_DIR}/hardware.nix"
HW_CONFIG_FILE="$(mktemp)"
trap 'rm -f "$HW_CONFIG_FILE"' EXIT

if [[ -f "$HW_FILE" ]]; then
    echo "Error: Hardware module already exists at $HW_FILE"
    exit 1
fi

if [[ ! -d "$HOST_DIR" ]]; then
    echo "Error: Host directory does not exist at $HOST_DIR; create the host first"
    exit 1
fi

if [[ -n "$INPUT_FILE" ]]; then
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: Hardware input file not found at $INPUT_FILE"
        exit 1
    fi
    cp "$INPUT_FILE" "$HW_CONFIG_FILE"
elif [[ "$ROOT_SPECIFIED" == true ]]; then
    nixos-generate-config --show-hardware-config "${GENERATOR_ARGS[@]}" > "$HW_CONFIG_FILE"
else
    echo "Error: provide --input FILE; collect hardware from the target or installer first"
    exit 1
fi

python3 - "$TEMPLATE_FILE" "$HW_CONFIG_FILE" "$HW_FILE" "$HOSTNAME" <<'PY'
from pathlib import Path
import sys

template_path, config_path, output_path, hostname = sys.argv[1:]
template = Path(template_path).read_text()
hardware_config = Path(config_path).read_text().strip()
output = template.replace("HOSTNAME_PLACEHOLDER", hostname).replace(
    "HW_CONFIG_PLACEHOLDER", hardware_config
)
Path(output_path).write_text(output)
PY

nix fmt "$HW_FILE" -- --quiet
git add "$HW_FILE"

echo "✓ Created hardware module at $HW_FILE"
echo ""
echo "Next steps:"
echo "1. For a new host, ensure '(hardware ${HOSTNAME})' is in the host aspect's includes"
