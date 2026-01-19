import re
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import sys

pref = sys.argv[1]

input_file = pref + ".fa"
output_file = pref + "_pseudo.fa"

cdr_patterns = {
    'CDR1': re.compile(r'CDR1\([^)]+\):[^=]+=([A-Z]+)'),
    'CDR2': re.compile(r'CDR2\([^)]+\):[^=]+=([A-Z]+)'),
    'CDR3': re.compile(r'CDR3\([^)]+\):[^=]+=([A-Z]+)')
}

output_records = []

for record in SeqIO.parse(input_file, "fasta"):
    header = record.description

    cdr_seqs = []
    for pattern in cdr_patterns.values():
        m = pattern.search(header)
        if not m:
            break
        cdr_seqs.append(m.group(1))

    # Only keep sequences with all three CDRs
    if len(cdr_seqs) == 3:
        pseudo_seq = "".join(cdr_seqs)

        new_rec = SeqRecord(
            Seq(pseudo_seq),
            id=record.id,
            description=f"pseudoCDR len={len(pseudo_seq)}"
        )
        output_records.append(new_rec)

SeqIO.write(output_records, output_file, "fasta")

print(f"{pref}: wrote {len(output_records)} pseudo sequences")
