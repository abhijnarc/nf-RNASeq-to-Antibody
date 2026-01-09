import pandas as pd
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
from Bio import SeqIO
import os
import subprocess

# Load AIRR files
heavy_df = pd.read_csv("heavy166780_filtered.airr", sep="\t")
light_df = pd.read_csv("light166780_filtered.airr", sep="\t")

heavy_seqs = heavy_df["sequence_aa"].dropna().tolist()
light_seqs = light_df["sequence_aa"].dropna().tolist()

min_len = min(len(heavy_seqs), len(light_seqs))
print(f"✅ Attempting to process {min_len} heavy-light pairs...")

# Create output folder
output_dir = "paired_fastas_riot"
os.makedirs(output_dir, exist_ok=True)

# Track failed sequences
failed_pairs = []

# Function to run RIOT on a single sequence
def run_riot(seq):
    cmd = f"riot_na --input-type aa -s {seq}"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0 or not result.stdout.strip():
        return None
    try:
        return eval(result.stdout.strip())["sequence_alignment_aa"]
    except Exception as e:
        return None

# Process each pair
for i in range(min_len):
    vh = heavy_seqs[i]
    vl = light_seqs[i]

    vh_aligned = run_riot(vh)
    vl_aligned = run_riot(vl)

    if not vh_aligned or not vl_aligned:
        print(f"⚠️ Skipping pair {i+1} due to RIOT failure.")
        failed_pairs.append((i+1, vh if not vh_aligned else None, vl if not vl_aligned else None))
        continue

    # Write single-line FASTA
    pair_file = os.path.join(output_dir, f"pair_{i+1}.fa")
    with open(pair_file, "w") as f:
        f.write(f">VH\n{vh_aligned}\n>VL\n{vl_aligned}\n")

print(f"\n✅ Finished. Paired FASTA files saved in: {output_dir}")
if failed_pairs:
    print("❌ RIOT failures for the following pairs:")
    for pair in failed_pairs:
        idx, vh_fail, vl_fail = pair
        print(f"  Pair {idx}: {'VH' if vh_fail else ''} {'VL' if vl_fail else ''}".strip())
