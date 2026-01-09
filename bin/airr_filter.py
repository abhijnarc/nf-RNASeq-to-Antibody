import pandas as pd

# --- Step 1: Input filenames ---
airr_file = input("Enter AIRR .tsv file to filter: ").strip()

# --- Step 2: List of excluded sequence IDs (example) ---
# NOTE: These must match exactly with the values in the 'sequence_id' column.
excluded_ids = {}  # add or load as needed

# --- Step 3: Load AIRR file ---
df = pd.read_csv(airr_file, sep="\t")
# --- Step 4: Filter
# Keep rows where 'productive' is NOT 'F' and not in excluded_ids
filtered_df = df[
    (df["productive"] != "F") &
    (~df["sequence_id"].isin(excluded_ids))
]

# --- Step 5: Save filtered AIRR file ---
output_file = airr_file.replace(".airr", "_filtered.airr")
filtered_df.to_csv(output_file, sep="\t", index=False)

print(f"✅ Filtered AIRR file saved as: {output_file}")
print(f"🧪 Kept {len(filtered_df)} sequences")