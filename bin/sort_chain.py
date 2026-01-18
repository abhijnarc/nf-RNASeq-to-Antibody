import csv
from Bio import SeqIO

# Input files
csv_file = "seq_summary_cad.csv"        
fasta_file = "cad_filtered.fa"   

# Output files
heavy_output = "cad_heavy_nonpseudo.fa"
light_output = "cad_light_nonpseudo.fa"

# Step 1: Parse seq_summary.csv to extract sequence IDs and classifi>
def parse_csv(csv_file):
    heavy_ids = []
    light_ids = []
    order = []

    with open(csv_file, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            seq_id = row['contig']
            category = row['chain']
            order.append(seq_id)
            if category.lower() == "heavy":
                heavy_ids.append(seq_id)
            elif category.lower() == "light":
                light_ids.append(seq_id)
    return heavy_ids, light_ids, order
# Step 2: Split sequences from FASTA file based on classification
def split_fasta(fasta_file, heavy_ids, light_ids, order, heavy_output, light_output):
    heavy_file = open(heavy_output, 'w')
    light_file = open(light_output, 'w')

    # Create a dictionary of all sequences for faster lookup
    sequences = {record.id: record for record in SeqIO.parse(fasta_file, "fasta")}

    # Write sequences in the order specified in the CSV file
    for seq_id in order:
        if seq_id in heavy_ids and seq_id in sequences:
            SeqIO.write(sequences[seq_id], heavy_file, "fasta")
        elif seq_id in light_ids and seq_id in sequences:
            SeqIO.write(sequences[seq_id], light_file, "fasta")

    heavy_file.close()
    light_file.close()

# Main Function
def main():
    heavy_ids, light_ids, order = parse_csv(csv_file)
    split_fasta(fasta_file, heavy_ids, light_ids, order, heavy_output, light_output)
    print("Sequences have been split into:")
    print(f"- {heavy_output} (Heavy sequences)")
    print(f"- {light_output} (Light sequences)")

if __name__ == "__main__":
    main()
