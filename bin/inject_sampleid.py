from Bio import SeqIO
import sys

sample = sys.argv[1]
input_fa = sys.argv[2]
output_fa = sys.argv[3]

with open(input_fa) as inp, open(output_fa, "w") as out:
    for rec in SeqIO.parse(inp, "fasta"):
        # prepend sample ID to original TRUST4 ID
        rec.id = f"{sample}|{rec.id}"
        rec.description = rec.id
        SeqIO.write(rec, out, "fasta")
