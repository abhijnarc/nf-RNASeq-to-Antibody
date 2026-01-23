#!/usr/bin/env python3
"""
ImmunoMatch sequence search wrapper
Queries sequences against ImmunoMatch database for similar antibodies
"""

import sys
from Bio import SeqIO
import csv
from immuno_match import ImmunoMatch

def main():
    input_fasta = sys.argv[1]
    group = sys.argv[2]
    chain = sys.argv[3]
    output_csv = sys.argv[4]

    # Initialize ImmunoMatch client
    matcher = ImmunoMatch()

    # Results storage
    results = []

    # Process each sequence
    for record in SeqIO.parse(input_fasta, "fasta"):
        sequence = str(record.seq)
        seq_id = record.id

        try:
            # Query ImmunoMatch database
            matches = matcher.search(sequence, chain_type=chain.upper())
            
            for match in matches:
                results.append({
                    'sequence_id': seq_id,
                    'group': group,
                    'chain': chain,
                    'query_sequence': sequence[:50] + '...',
                    'match_id': match.get('id', 'N/A'),
                    'match_description': match.get('description', 'N/A'),
                    'identity': match.get('identity', 0),
                    'e_value': match.get('e_value', 1.0)
                })
        except Exception as e:
            print(f"Warning: Error processing {seq_id}: {e}", file=sys.stderr)
            continue

    # Write results to CSV
    if results:
        with open(output_csv, 'w', newline='') as f:
            fieldnames = results[0].keys()
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(results)
    else:
        # Create empty CSV with headers if no matches
        with open(output_csv, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['sequence_id', 'group', 'chain', 'query_sequence', 
                           'match_id', 'match_description', 'identity', 'e_value'])

if __name__ == '__main__':
    main()
