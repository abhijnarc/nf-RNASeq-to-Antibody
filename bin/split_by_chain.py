from Bio import SeqIO
import pandas as pd
import sys

group = sys.argv[1]

fasta_in = f"{group}_filtered.fa"
csv_in   = f"seq_summary_{group}.csv"

heavy_out = f"{group}_heavy.fa"
light_out = f"{group}_light.fa"

df = pd.read_csv(csv_in)

# contig = renumbered ID (e.g. CAD_000123)
contig_to_chain = dict(zip(df["contig"], df["chain"]))

heavy = []
light = []

for rec in SeqIO.parse(fasta_in, "fasta"):
    contig = rec.id  # already renumbered

    chain = contig_to_chain.get(contig)
    if chain == "heavy":
        heavy.append(rec)
    elif chain == "light":
        light.append(rec)

SeqIO.write(heavy, heavy_out, "fasta")
SeqIO.write(light, light_out, "fasta")

print(f"{group}: heavy={len(heavy)}, light={len(light)}")
