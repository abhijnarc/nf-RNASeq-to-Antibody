#!/bin/bash
# filepath: /data/athero/GSE173983/fastp.sh

# Usage: ./fastp.sh <directory_with_fastq.gz_files>
DIR="$1"
if [ -z "$DIR" ]; then
    echo "Usage: $0 <directory_with_fastq.gz_files>"
    exit 1
fi

for r1 in "$DIR"/*_R1_001*.fastq.gz; do
    [ -e "$r1" ] || continue
    samp=$(basename "$r1" | sed 's/_R1_001.*\.fastq\.gz//')
    r2="$DIR/${samp}_R2_001.fastq.gz"
    # If your files are named *_R1_001.fastq.gz and *_R2_001.fastq.gz, adjust above accordingly
    if [ ! -e "$r2" ]; then
        echo "Paired file for $r1 not found, skipping."
        continue
    fi
    out1="$DIR/${samp}_fastp_1.fastq.gz"
    out2="$DIR/${samp}_fastp_2.fastq.gz"
    rep_file="$DIR/${samp}_fastp.html"
    echo "Processing sample: $samp"
    /home/user/tools/fastp --in1 "$r1" --in2 "$r2" \
        --out1 "$out1" --out2 "$out2" \
        --qualified_quality_phred 30 \
        --detect_adapter_for_pe \
        --correction \
        --trim_tail1=1 \
        --cut_tail \
        --cut_window_size=4 \
        --cut_mean_quality=30 \
        --length_required=50 \
        --html "$rep_file"
done