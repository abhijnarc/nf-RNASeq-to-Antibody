from Bio import SeqIO
import sys

sample = sys.argv[1]
input_fa = sys.argv[2]
output_fa = sys.argv[3]

with open(input_fa) as inp, open(output_fa, "w") as out:
    for rec in SeqIO.parse(inp, "fasta"):
        old_id = rec.id
        old_desc = rec.description

        # Inject sample ID into the contig ID only
        rec.id = f"{sample}|{old_id}"

        # Preserve full TRUST4 metadata
        rec.description = f"{rec.id} {old_desc[len(old_id):].lstrip()}"

        SeqIO.write(rec, out, "fasta")
