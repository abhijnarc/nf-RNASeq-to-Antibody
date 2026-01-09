import re
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import sys

pref = sys.argv[1]

def extract_cdr_sequences(input_file, output_file):
    """
    Extract CDR1, CDR2, and CDR3 sequences from FASTA headers and concatenate them.
    Output is written in single-line FASTA format.
    """
    # Updated regex patterns to match format: CDR1(coordinates):score=sequence
    cdr_patterns = {
        'CDR1': re.compile(r'CDR1\([^)]+\):[^=]+=([A-Z]+)'),
        'CDR2': re.compile(r'CDR2\([^)]+\):[^=]+=([A-Z]+)'),
        'CDR3': re.compile(r'CDR3\([^)]+\):[^=]+=([A-Z]+)')
    }
    
    output_records = []
    
    # Process each sequence in the FASTA file
    for record in SeqIO.parse(input_file, "fasta"):
        header = record.description
        
        # Extract CDR regions
        cdr_sequences = []
        for cdr_name, pattern in cdr_patterns.items():
            match = pattern.search(header)
            if match:
                cdr_seq = match.group(1)
                cdr_sequences.append(cdr_seq)
                print(f"Found {cdr_name}: {cdr_seq}")  # Debug print
        
        if len(cdr_sequences) == 3:  # Only process if all CDRs are found
            # Concatenate CDR sequences
            combined_seq = ''.join(cdr_sequences)
            
            # Create new record with concatenated sequence
            new_record = SeqRecord(
                Seq(combined_seq),
                id=record.id,
                description=f"concatenated_CDRs_{len(combined_seq)}bp"
            )
            output_records.append(new_record)
    
    # Write sequences in single-line FASTA format
    with open(output_file, 'w') as f:
        for record in output_records:
            header = f">{record.id} {record.description}\n"
            sequence = f"{str(record.seq)}\n"
            f.write(header)
            f.write(sequence)
    
    print(f"Found {len(output_records)} sequences")
    print(f"Processed sequences written to {output_file}")

# Example usage
if __name__ == "__main__":
    input_file = pref + "_filtered.fa"
    output_file = pref + "_pseudo.fa"
    extract_cdr_sequences(input_file, output_file)
