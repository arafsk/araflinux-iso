#!/bin/bash

# === CONFIGURATION ===
file1="/home/arafsk/Desktop/pkglist.txt"
file2="/home/arafsk/DATA/github/arafsk/arafos-iso/archiso/packages.x86_64"
output="/home/arafsk/Desktop/FINAL_gnome_packages.txt"

# === HELPER: normalize any file to sorted unique one-per-line ===
normalize() {
    local input="$1"
    local output="$2"
    if [[ $(wc -l < "$input") -eq 1 ]]; then
        # Single line → assume space-separated
        tr ' ' '\n' < "$input" | grep -v '^[[:space:]]*$' | sort -u > "$output"
    else
        # Already multi-line → just clean and sort
        grep -v '^[[:space:]]*$' "$input" | sort -u > "$output"
    fi
}

# === MAIN ===
if [[ ! -f "$file1" ]]; then echo "❌ $file1 not found!"; exit 1; fi
if [[ ! -f "$file2" ]]; then echo "❌ $file2 not found!"; exit 1; fi

# Normalize both files
norm1=$(mktemp)
norm2=$(mktemp)
normalize "$file1" "$norm1"
normalize "$file2" "$norm2"

# Compute sets
common=$(comm -12 "$norm1" "$norm2")
only1=$(comm -23 "$norm1" "$norm2")   # in file1 only
only2=$(comm -13 "$norm1" "$norm2")   # in file2 only

# Output clean report
{
    echo "=== COMMON (in both $file1 and $file2) ==="
    if [[ -n "$common" ]]; then echo "$common"; else echo "(none)"; fi

    echo -e "\n=== MISSING (in $file1 but NOT in $file2) ==="
    if [[ -n "$only1" ]]; then echo "$only1"; else echo "(none)"; fi

    echo -e "\n=== EXTRA (in $file2 but NOT in $file1) ==="
    if [[ -n "$only2" ]]; then echo "$only2"; else echo "(none)"; fi
} > "$output"

# Cleanup
rm -f "$norm1" "$norm2"

echo "✅ Clean report saved to: $output"
