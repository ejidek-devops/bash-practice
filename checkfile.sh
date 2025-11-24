#!/bin/bash

# =======================================================
# name: Adekunle
# date: 2025
# version: 2.0.0
# about: Scan .txt files in a directory and report word and
#        letter counts per file and totals.
# Usage: ./checkfile.sh [directory]
# =======================================================

set -euo pipefail

DIR="${1:-.}"

if [ ! -d "$DIR" ]; then
	echo "Directory '$DIR' does not exist." >&2
	exit 2
fi

echo "Scanning directory: $DIR for .txt files"

# Find .txt files (non-recursive). Handle filenames with spaces/newlines.
mapfile -d '' files < <(find "$DIR" -maxdepth 1 -type f -name "*.txt" -print0)

if [ ${#files[@]} -eq 0 ]; then
	echo "No .txt files found in '$DIR'."
	exit 0
fi

total_words=0
total_letters=0

printf "%-40s %12s %12s\n" "Filename" "Words" "Letters"
printf "%s\n" "$(printf '=%.0s' {1..68})"

for f in "${files[@]}"; do
	# wc -w gives word count
	words=$(wc -w < "$f" | tr -d '[:space:]' || echo 0)

	# letters: count only alphabetic characters (A-Z, a-z)
	letters=$(grep -o '[A-Za-z]' "$f" 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)

	total_words=$((total_words + words))
	total_letters=$((total_letters + letters))

	printf "%-40s %12s %12s\n" "$(basename "$f")" "$words" "$letters"
done

printf '%s\n' "$(printf '%.0s-' {1..68})"
printf "%-40s %12s %12s\n" "TOTAL" "$total_words" "$total_letters"

exit 0


