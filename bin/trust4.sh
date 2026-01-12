#!/bin/bash
set -euo pipefail

R1="$1"
R2="$2"
SAMPLE="$3"
ORGANISM="$4"

# Select reference files based on organism
if [[ "$ORGANISM" == "rabbit" ]]; then
    ref_file=/home/user/tools/TRUST4/rabbit/rabbit_IMGT+C.fa
elif [[ "$ORGANISM" == "human" ]]; then
    ref_file=/home/user/tools/TRUST4/human/human_IMGT+C.fa
else
    echo "ERROR: organism must be 'human' or 'rabbit'"
    exit 1
fi

# Create output directory
mkdir -p "${SAMPLE}"

# Run TRUST4 (use -f and --ref as same file)
/home/user/tools/TRUST4/run-trust4 \
  -1 "$R1" \
  -2 "$R2" \
  -f "$ref_file" \
  --ref "$ref_file" \
  -t 40 \
  --od "${SAMPLE}" \
  -o "${SAMPLE}"
