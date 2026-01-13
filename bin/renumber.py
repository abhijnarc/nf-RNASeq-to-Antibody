from Bio import SeqIO
import csv
import sys
import re

group = sys.argv[1]

input_fasta = f"{group}_annot.fa"
output_fasta = f"{group}_renum_annot.fa"
mapping_csv = f"id_mapping_{group}.csv"

def extract_sample(header):
    """
    Try common TRUST4 header patterns to get sample ID.
    """
    # pattern: sample=SRRxxxx
    m = re.search(r"sample=([A-Za-z0-9_]+)", header)
    if m:
        return m.group(1)

    # pattern: SRRxxxx as standalone token
    m = re.search(r"(SRR\d+)", header)
    if m:
        return m.group(1)

    return "UNKNOWN"

with open(input_fasta, "r") as in_fa, \
     open(output_fasta, "w") as out_fa, \
     open(mapping_csv, "w", newline="") as csvfile:

    writer = csv.writer(csvfile)
    writer.writerow(["group", "sample", "original_id", "new_id", "full_header"])

    counter = 1

    for record in SeqIO.parse(in_fa, "fasta"):
        old_id = record.id
        full_header = record.description

        sample_id = extract_sample(full_header)
        new_id = f"{group}_{counter:06d}"
        counter += 1

        rest_of_header = full_header[len(old_id):].lstrip()
        new_header = f"{new_id} {rest_of_header}".strip()

        writer.writerow([
            group,
            sample_id,
            old_id,
            new_id,
            full_header
        ])

        record.id = new_id
        record.description = new_header
        SeqIO.write(record, out_fa, "fasta")
