#!/bin/bash
set -euo pipefail

R1="$1"
R2="$2"
SAMPLE="$3"

out1="${SAMPLE}_fastp_1.fastq.gz"
out2="${SAMPLE}_fastp_2.fastq.gz"
rep_file="${SAMPLE}_fastp.html"

/home/user/tools/fastp \
  --in1 "$R1" \
  --in2 "$R2" \
  --out1 "$out1" \
  --out2 "$out2" \
  --qualified_quality_phred 30 \
  --detect_adapter_for_pe \
  --correction \
  --trim_tail1=1 \
  --cut_tail \
  --cut_window_size=4 \
  --cut_mean_quality=30 \
  --length_required=50 \
  --html "$rep_file"
