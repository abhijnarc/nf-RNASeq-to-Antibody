#!/usr/bin/env python3
from Bio import SeqIO
import re
import csv
import sys

# Usage: python reorder_fasta_and_save_counts.py master.fasta input.fasta output.fasta output.csv

if len(sys.argv) != 5:
    print("Usage: python reorder_fasta_and_save_counts.py <master.fasta> <input.fasta> <output.fasta> <output.csv>")
    sys.exit(1)

master_fasta = sys.argv[1]
input_fasta = sys.argv[2]
output_fasta = sys.argv[3]
output_csv = sys.argv[4]

# --- Step 1: Parse expression counts from master FASTA ---
expr_counts = {}
for record in SeqIO.parse(master_fasta, "fasta"):
    # Match pattern like ">assemble3 846 ..." or ">assemble4 825 ..."
    match = re.match(r"^(\S+)\s+(\d+)", record.description)
    if match:
        seq_id, count = match.groups()
        expr_counts[seq_id] = int(count)

# --- Step 2: Load input FASTA sequences ---
input_records = list(SeqIO.parse(input_fasta, "fasta"))

# --- Step 3: Sort by expression count (descending) ---
input_records.sort(key=lambda r: expr_counts.get(r.id, 0), reverse=True)

# --- Step 4: Write sorted sequences to output FASTA ---
SeqIO.write(input_records, output_fasta, "fasta")

# --- Step 5: Write identifier + expression count to CSV ---
with open(output_csv, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["Identifier", "Expression_Count"])
    for record in input_records:
        writer.writerow([record.id, expr_counts.get(record.id, 0)])

print(f"✅ Done!\n- Sorted FASTA written to: {output_fasta}\n- CSV summary written to: {output_csv}")
