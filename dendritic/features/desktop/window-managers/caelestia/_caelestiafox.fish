# Native messaging protocol used by upstream CaelestiaFox's app.fish:
# https://github.com/caelestia-dots/caelestia/tree/main/firefox/native_app
function message -a msg
    # Firefox expects the UTF-8 byte length as a 4-byte little-endian integer.
    set -l size (printf '%08X' (printf '%s' "$msg" | wc -c | string trim))
    printf '%b' "\\x$(string sub -s 7 -l 2 $size)\\x$(string sub -s 5 -l 2 $size)\\x$(string sub -s 3 -l 2 $size)\\x$(string sub -s 1 -l 2 $size)"
    printf '%s' "$msg"
end

set -l state "$HOME/.local/state"
if set -q XDG_STATE_HOME; and test -n "$XDG_STATE_HOME"
    set state "$XDG_STATE_HOME"
end
set -l state_dir "$state/caelestia"
set -l scheme_path "$state_dir/scheme.json"

# The browser can start before Caelestia first generates a scheme.
mkdir -p "$state_dir"

# Send the initial scheme, then stream changes through the same connection.
inotifywait -q -e close_write,moved_to,create -m "$state_dir" | begin
    if test -f "$scheme_path"
        set -l scheme (jq -c . "$scheme_path")
        if test $status -eq 0
            message "$scheme"
        end
    end
    while read -l dir events file
        if test "$dir$file" = "$scheme_path"
            set -l scheme (jq -c . "$scheme_path")
            if test $status -eq 0
                message "$scheme"
            end
        end
    end
end
