#!/bin/sh
set -eu

repo_root=$(
    CDPATH= cd -- "$(dirname -- "$0")/.." && pwd
)

tmpdir=$(mktemp -d)
cleanup() {
    rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

mkdir -p "$tmpdir/cable"

awk '
    /^\[source\]$/ {
        in_source = 1
        print
        next
    }

    in_source && /^command = / {
        print "command = \"printf '\''first line\\\\nsecond line\\\\000single line\\\\000'\''\""
        in_source = 0
        next
    }

    { print }
' "$repo_root/.config/television/cable/fish-history.toml" > "$tmpdir/cable/fish-history.toml"

output=$(
    tv fish-history \
        --cable-dir "$tmpdir/cable" \
        --take-1 \
        --no-preview \
        --no-status-bar
)

expected_file="$tmpdir/expected"
actual_file="$tmpdir/actual"
printf 'first line\nsecond line' > "$expected_file"
printf '%s' "$output" > "$actual_file"

if ! cmp -s "$expected_file" "$actual_file"; then
    echo "expected:"
    sed -n l "$expected_file"
    echo "actual:"
    sed -n l "$actual_file"
    exit 1
fi
