#!/bin/bash
set -euo pipefail

R1="$1"
R2="$2"
SAMPLE="$3"
ORGANISM="$4"
REFDIR="$5"

OUTDIR="${SAMPLE}"
mkdir -p "${OUTDIR}"

if [[ "$ORGANISM" == "human" ]]; then
  REF_FASTA="${REFDIR}/hg38_bcrtcr.fa"
  IMGT_FASTA="${REFDIR}/human_IMGT+C.fa"
elif [[ "$ORGANISM" == "rabbit" ]]; then
  REF_FASTA="${REFDIR}/GRCm38_bcrtcr.fa"
  IMGT_FASTA="${REFDIR}/rabbit_IMGT+C.fa"
else
  echo "Unknown organism: $ORGANISM"
  exit 1
fi

trust4 \
  -1 "$R1" \
  -2 "$R2" \
  -f "$REF_FASTA" \
  -i "$IMGT_FASTA" \
  -o "${OUTDIR}/${SAMPLE}"
