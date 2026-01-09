# Filename: parse_fasta_lengths.py

def parse_fasta_lengths(filepath):
    with open(filepath, 'r') as file:
        for line in file:
            if line.startswith('>'):
                parts = line.strip().split()
                if len(parts) >= 2:
                    identifier = parts[0][1:]  # remove '>'
                    length = parts[1]
                    print(f"{identifier}\t{length}")

# Example usage
parse_fasta_lengths("macir_heavy_igb.fa")
