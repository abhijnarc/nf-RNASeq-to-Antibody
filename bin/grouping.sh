#!/bin/bash
set -euo pipefail

GROUP="$1"
shift
FASTAS="$@"

cat ${FASTAS} > ${GROUP}_annot.fa

python renumber.py ${GROUP}
