import csv
from Bio import SeqIO

def parse_clusters(tsv_file):
    remove_ids = set()
    
    with open(tsv_file, newline='') as f:
        reader = csv.reader(f, delimiter='\t')  # use '\t' for TSV
        for row in reader:
            row = [x.strip() for x in row if x.strip()]
            has_assemble = any("assemble" in x for x in row)
            has_control = any("control" in x for x in row)
            
            if has_assemble and has_control:
                remove_ids.update(row)
    
    return remove_ids


def filter_fasta(fasta_in, fasta_out, remove_ids):
    records = SeqIO.parse(fasta_in, "fasta")
    with open(fasta_out, "w") as f:
        SeqIO.write((r for r in records if r.id not in remove_ids), f, "fasta")

# --- USAGE ---
cluster_csv = "Lclusters.tsv"         # Your input cluster file (converted from the image)
fasta_input = "S4_light_nonpseudo.fa"   # Your input FASTA
fasta_output = "S4_LNSF.fa"

remove_ids = parse_clusters(cluster_csv)
filter_fasta(fasta_input, fasta_output, remove_ids)
