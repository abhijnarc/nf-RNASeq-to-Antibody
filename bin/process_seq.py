# -*- coding: utf-8 -*-
"""
Script to parse TRUST4 output sequences using SeqIO from Biopython
(Updated to support sampleID|assembleID headers)
"""

import pandas as pd
from Bio import SeqIO
import re
import sys

# get prefix from argument (group name: CAD / CTL)
pref = sys.argv[1]

# input filename
fasta_file = pref + '_renum_annot.fa'

# parse the fasta file
allseq = SeqIO.parse(fasta_file, 'fasta')

# containers
seqsum = []
filt_seq = []
nfilt = 0

for record in allseq:
    header = record.description

    # -------------------------------------------------
    # Handle injected sample ID (SRR|assembleX ...)
    # -------------------------------------------------
    if '|' in header:
        _, trust4_part = header.split('|', 1)
    else:
        trust4_part = header

    fields = trust4_part.split()

    # Guard against malformed headers
    if len(fields) < 4:
        continue  # or raise ValueError if you want strict failure

    contig = fields[0]
    conlen = fields[1]

    try:
        concov = float(fields[2])
    except ValueError:
        continue

    vloctemp = fields[3]
    vloci = vloctemp.split('*')[0]

    # -------------------------------------------------
    # Chain assignment
    # -------------------------------------------------
    if vloci:
        if 'IGH' in vloci:
            chain = 'heavy'
        else:
            chain = 'light'
    else:
        continue

    # -------------------------------------------------
    # Extract CDR scores
    # -------------------------------------------------
    try:
        cdr1_score = int(re.search(r'CDR1\(\d+\-\d+\)\:(\d+)', header).group(1))
        cdr2_score = int(re.search(r'CDR2\(\d+\-\d+\)\:(\d+)', header).group(1))
        cdr3_score = int(re.search(r'CDR3\(\d+\-\d+\)\:(\d+)', header).group(1))
    except AttributeError:
        continue

    sumscore = cdr1_score + cdr2_score + cdr3_score
    nonzero = (cdr1_score > 0) and (cdr2_score > 0) and (cdr3_score > 0)

    # -------------------------------------------------
    # Filtering logic (unchanged)
    # -------------------------------------------------
    if nonzero and concov >= 10:
        nfilt += 1

        seqsum.append({
            'contig': contig,
            'chain': chain,
            'coverage': concov,
            'CDR1score': cdr1_score,
            'CDR2score': cdr2_score,
            'CDR3score': cdr3_score,
            'Sumscore': sumscore
        })

        filt_seq.append(record)

# -------------------------------------------------
# Output
# -------------------------------------------------
seq_df = pd.DataFrame(seqsum)

if not seq_df.empty:
    seq_sort = seq_df.sort_values(
        by=['chain', 'Sumscore'],
        ascending=[True, False]
    )
else:
    seq_sort = seq_df

out_file = 'seq_summary_' + pref + '.csv'
seq_sort.to_csv(out_file, encoding='utf-8', index=False)

fasta_out = pref + '_filtered.fa'
SeqIO.write(filt_seq, fasta_out, 'fasta')

print(f"No of filtered sequences = {nfilt}")
