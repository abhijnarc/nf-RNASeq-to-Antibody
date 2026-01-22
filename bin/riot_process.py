import pandas as pd
import os
import subprocess
import sys

# --- Input parameters ---
airr_file = sys.argv[1]      # e.g., CAD_heavy.airr
group = sys.argv[2]          # e.g., CAD
chain = sys.argv[3]          # e.g., heavy or light
output_fasta = sys.argv[4]   # e.g., CAD_heavy_riot.fa

# --- Step 1: Load AIRR file ---
try:
    df = pd.read_csv(airr_file, sep="\t")
except Exception as e:
    print(f"❌ Error loading AIRR file: {e}")
    sys.exit(1)

# --- Step 2: Filter for productive sequences ---
# Keep rows where 'productive' is NOT 'F' and has sequence_aa
filtered_df = df[
    (df.get("productive", "") != "F") &
    (df["sequence_aa"].notna()) &
    (df["sequence_aa"].str.len() > 0)
]

print(f"📊 Original sequences: {len(df)}")
print(f"✅ After filtering non-productive: {len(filtered_df)}")

if len(filtered_df) == 0:
    # Create empty output file
    with open(output_fasta, "w") as f:
        pass
    print(f"⚠️ No productive sequences found. Empty FASTA written.")
    sys.exit(0)

# --- Step 3: Run RIOT on filtered sequences ---
riot_success = 0
failed_seqs = []
riot_results = {}

for i, row in filtered_df.iterrows():
    seq = row["sequence_aa"]
    seq_id = str(row.get("sequence_id", f"{chain}_{i+1}"))

    # Run RIOT
    cmd = f"riot_na --input-type aa -s {seq}"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    
    if result.returncode != 0 or not result.stdout.strip():
        failed_seqs.append(seq_id)
        continue
    
    try:
        riot_output = eval(result.stdout.strip())
        riot_seq = riot_output.get("sequence_alignment_aa")
        if riot_seq:
            riot_results[seq_id] = riot_seq
            riot_success += 1
        else:
            failed_seqs.append(seq_id)
    except Exception as e:
        failed_seqs.append(seq_id)

print(f"🧪 RIOT succeeded for {riot_success}/{len(filtered_df)} sequences")

# --- Step 4: Write successful sequences to FASTA ---
with open(output_fasta, "w") as out_f:
    for seq_id, riot_seq in riot_results.items():
        out_f.write(f">{seq_id}\n{riot_seq}\n")

print(f"📁 RIOT-processed {chain} chain sequences written to: {output_fasta}")

if failed_seqs:
    print(f"⚠️ RIOT failed for {len(failed_seqs)} sequences")
