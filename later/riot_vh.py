import pandas as pd
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
from Bio import SeqIO
import os
import subprocess

# Load heavy chain AIRR file only
heavy_df = pd.read_csv("top5.airr", sep="\t")

# Drop sequences with no amino acid translation
heavy_seqs = heavy_df["sequence_aa"].dropna().tolist()
print(f"✅ Processing {len(heavy_seqs)} heavy chains...")

# Create output directory
#output_dir = "vh_fastas_riot"

#os.makedirs(output_dir, exist_ok=True)

# Track RIOT stats
riot_success = 0
failed_seqs = []

# Function to run RIOT on a single sequence
def run_riot(seq):
    cmd = f"riot_na --input-type aa -s {seq}"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0 or not result.stdout.strip():
        return None
    try:
        return eval(result.stdout.strip())["sequence_alignment_aa"]
    except Exception:
        return None

# Process each heavy chain
for i, seq in enumerate(heavy_seqs):
    vh_riot = run_riot(seq)
    used_fallback = False

    if not vh_riot:
        print(f"⚠️ RIOT failed for nb{i+1}. Using sequence_aa fallback.")
        vh_riot = seq
        used_fallback = True
        failed_seqs.append((i+1, seq))

    else:
        riot_success += 1

    # Write to FASTA: nb1.fa, nb2.fa, ...
    filename = os.path.join(f"nb{i+1}.fa")
    with open(filename, "w") as f:
        f.write(f">VH\n{vh_riot}\n")

# Summary

print(f"🧪 RIOT succeeded for {riot_success}/{len(heavy_seqs)} sequences.")
if failed_seqs:
    print(f"❌ Fallback used for {len(failed_seqs)} sequences.")
