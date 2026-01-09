import pandas as pd
from Bio.Seq import Seq
import os
import subprocess

# Load light chain AIRR file
light_df = pd.read_csv("S34_light_filtered.airr", sep="\t")

# Drop sequences with no amino acid translation
light_df = light_df.dropna(subset=["sequence_aa"])
print(f"✅ Processing {len(light_df)} light chains...")

# Create output directory
output_dir = "vl_fastas_riot"
os.makedirs(output_dir, exist_ok=True)

# Output files
combined_fasta = os.path.join(output_dir, "vl_all_riot.fasta")
failed_log = os.path.join(output_dir, "vl_failed_sequences.txt")

# Track stats
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

# Run RIOT and write only successful sequences
with open(combined_fasta, "w") as out_f:
    for i, row in light_df.iterrows():
        seq = row["sequence_aa"]
        seq_id = str(row["sequence_id"]) if "sequence_id" in row else f"vl{i+1}"

        vl_riot = run_riot(seq)

        if vl_riot:
            riot_success += 1
            out_f.write(f">{seq_id}\n{vl_riot}\n")
        else:
            failed_seqs.append(seq_id)
            print(f"❌ RIOT failed for {seq_id}, skipping.")

# Save failed sequence IDs to a log file
if failed_seqs:
    with open(failed_log, "w") as log_f:
        log_f.write("RIOT failed for the following sequence IDs:\n")
        for seq_id in failed_seqs:
            log_f.write(f"{seq_id}\n")

# Summary
print(f"🧪 RIOT succeeded for {riot_success}/{len(light_df)} sequences.")
print(f"📁 Aligned sequences written to: {combined_fasta}")
if failed_seqs:
    print(f"⚠️ Failed sequence IDs saved to: {failed_log}")
