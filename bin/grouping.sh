#!/bin/bash
set -euo pipefail

GROUP="$1"
PROJECT_DIR="$2"
shift 2
ANNOT_FASTAS="$@"

# Concatenate FASTAs
cat ${ANNOT_FASTAS} > ${GROUP}_annot.fa

# Call renumber script using explicit path
python "${PROJECT_DIR}/bin/renumber.py" "${GROUP}"
