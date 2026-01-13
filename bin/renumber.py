from Bio import SeqIO
import csv
import sys

pref = sys.argv[1] 

input_fasta = pref + "_annot.fa"
output_fasta = pref + "_renum_annot.fa"
mapping_csv = "id_mapping_" + pref+ ".csv"

def extract_identifier(header_line):
    return header_line.split()[0].replace(">", "")

with open(input_fasta, "r") as in_fa, \
     open(output_fasta, "w") as out_fa, \
     open(mapping_csv, "w", newline="") as csvfile:

    writer = csv.writer(csvfile)
    writer.writerow(["original_id", "new_id"])

    counter = 0
    for record in SeqIO.parse(in_fa, "fasta"):
        full_header = record.description
        old_id = record.id
        new_id = f"assemble{counter}"
        counter += 1

        # Replace only the ID at the start of the header
        rest_of_header = full_header[len(old_id):].lstrip()
        new_header = f"{new_id} {rest_of_header}".strip()

        writer.writerow([old_id, new_id])
        record.id = new_id
        record.description = new_header
        SeqIO.write(record, out_fa, "fasta")
