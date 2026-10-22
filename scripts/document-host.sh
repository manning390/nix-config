#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
DOCUMENT="$ROOT/docs/hosts.md"

for dependency in nix jq awk hostname; do
    if ! command -v "$dependency" >/dev/null; then
        printf 'Required command not found: %s\n' "$dependency" >&2
        exit 1
    fi
done

HOSTNAME="$(hostname)"
if [[ ! "$HOSTNAME" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    printf 'Unsupported hostname: %s\n' "$HOSTNAME" >&2
    exit 1
fi

# Evaluate metadata only; collecting documentation never builds a system.
METADATA="$(nix eval --json "$ROOT#hostMetadata")"
HOST="$(jq -ce --arg hostname "$HOSTNAME" '.[$hostname] // empty' <<< "$METADATA")" || {
    printf 'Local hostname %s is not registered in local.hosts\n' "$HOSTNAME" >&2
    exit 1
}

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

row() {
    jq -nr --arg label "$1" --arg value "$2" '
        def cell:
            gsub("\\s+"; " ") | sub("^ "; "") | sub(" $"; "")
            | gsub("&"; "&amp;") | gsub("<"; "&lt;")
            | gsub(">"; "&gt;") | gsub("\\|"; "&#124;");
        "| \($label | cell) | \($value | cell) |"
    '
}

size() {
    awk -v bytes="$1" 'BEGIN { printf "%.1f GiB", bytes / 1024^3 }'
}

read_optional() {
    if [[ -r "$1" ]]; then
        tr '\n' ' ' < "$1"
    fi
}

START="<!-- host:$HOSTNAME:start -->"
END="<!-- host:$HOSTNAME:end -->"
{
    printf '%s\n## %s\n\n| Property | Value |\n| --- | --- |\n' "$START" "${HOSTNAME^}"
    row Type "$(jq -r '.type' <<< "$HOST")"
    row Architecture "$(jq -r '.system' <<< "$HOST")"
    row Description "$(jq -r '.description // "Not specified in host aspect"' <<< "$HOST")"

    MACHINE="$(read_optional /sys/class/dmi/id/sys_vendor)$(read_optional /sys/class/dmi/id/product_name)"
    row Machine "${MACHINE:-Unavailable}"

    if CPU="$(lscpu --json 2>/dev/null)"; then
        row CPU "$(jq -r '[.lscpu[] | select(.field == "Model name:") | .data][0] // "Unavailable"' <<< "$CPU")"
        row 'Logical CPUs' "$(jq -r '[.lscpu[] | select(.field == "CPU(s):") | .data][0] // "Unavailable"' <<< "$CPU")"
    else
        row CPU 'Unavailable (lscpu not installed or query failed)'
    fi

    MEMORY="$(awk '$1 == "MemTotal:" { printf "%.1f GiB", $2 / 1024^2 }' /proc/meminfo 2>/dev/null || true)"
    row 'Memory (usable)' "${MEMORY:-Unavailable}"

    # Verbose machine-readable output avoids parsing quoted PCI device names.
    PCI="$(lspci -vmm 2>/dev/null || true)"
    GRAPHICS="$(awk '
        BEGIN { RS = ""; FS = "\n" }
        {
            class = vendor = device = ""
            for (i = 1; i <= NF; i++) {
                value = $i
                sub(/^[^:]+:[\t ]*/, "", value)
                if ($i ~ /^Class:/) class = value
                if ($i ~ /^Vendor:/) vendor = value
                if ($i ~ /^Device:/) device = value
            }
            if (class ~ /VGA|3D controller|Display controller/) {
                printf "%s%s %s", separator, vendor, device
                separator = "; "
            }
        }
    ' <<< "$PCI")"
    row Graphics "${GRAPHICS:-Unavailable / no PCI graphics device exposed}"

    DISKS="$(lsblk --json --bytes --nodeps --output NAME,TYPE,SIZE,MODEL,TRAN 2>/dev/null || printf '{"blockdevices":[]}')"
    jq -c '.blockdevices[] | select(.type == "disk")' <<< "$DISKS" > "$TEMP_DIR/disks"
    if [[ -s "$TEMP_DIR/disks" ]]; then
        while IFS= read -r disk; do
            NAME="$(jq -r '.name' <<< "$disk")"
            MODEL="$(jq -r '.model // "" | sub("^ +"; "") | sub(" +$"; "")' <<< "$disk")"
            TRANSPORT="$(jq -r '.tran // ""' <<< "$disk")"
            DETAILS="${MODEL:+$MODEL; }$(size "$(jq -r '.size' <<< "$disk")")"
            row "Disk /dev/$NAME" "$DETAILS${TRANSPORT:+; $TRANSPORT}"
        done < "$TEMP_DIR/disks"
    else
        row Disks 'Unavailable / no disks exposed'
    fi
    printf '\n%s\n' "$END"
} > "$TEMP_DIR/entry"

SOURCE="$DOCUMENT"
if [[ ! -f "$SOURCE" ]]; then
    SOURCE="$TEMP_DIR/intro"
    cat > "$SOURCE" <<'EOF'
# Hosts

Run `just document-host` on a host to update its entry.
EOF
fi

# Validate markers before publishing; a malformed entry leaves the file intact.
awk -v start="$START" -v end="$END" -v entry="$TEMP_DIR/entry" '
    function emit( line) {
        while ((getline line < entry) > 0) print line
        close(entry)
    }
    $0 == start {
        if (seen || inside) { invalid = 1; exit 1 }
        seen = inside = 1
        emit()
        next
    }
    $0 == end {
        if (!inside) { invalid = 1; exit 1 }
        inside = 0
        next
    }
    !inside { print }
    END {
        if (invalid || inside) exit 1
        if (!seen) { print ""; emit() }
    }
' "$SOURCE" > "$TEMP_DIR/document" || {
    printf 'Malformed or duplicate documentation markers for %s\n' "$HOSTNAME" >&2
    exit 1
}

cp "$TEMP_DIR/document" "$DOCUMENT"
printf 'Updated %s in docs/hosts.md\n' "$HOSTNAME"
