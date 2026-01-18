# -*- coding: utf-8 -*-
"""
Created on Thu Jul  4 13:10:18 2024

Script to parse the Trust4 output sequences using SeqIO from Biopython

@author: sujan
"""

import pandas as pd
from Bio import SeqIO
import re
import sys

# get prefix from argument

pref = sys.argv[1]
# input filename
fasta_file = pref + '_annot.fa'

# parse the fasta file
allseq = SeqIO.parse(fasta_file, 'fasta')

# create an empty list
seqsum = []
# create empty list of the filtered seq object
filt_seq = []
nfilt = 0
# run through the fasta records
for record in allseq:
    header = record.description
    contig = header.split()[0]
    conlen = header.split()[1]
    concov = float(header.split()[2])
    # get the V loci
    vloctemp = header.split()[3]
    vloci = vloctemp.split('*')[0]
    # go only if the V loci is mapped
    if vloci:
        if 'IGH' in vloci:
            chain = 'heavy'
        else:
            chain = 'light'
        # get the cdr scores by pattern match
       #cdr1_score = int(re.search('CDR1\(\d+\-\d+\)\:(\d+)', header).group(1))
        #cdr2_score = int(re.search('CDR2\(\d+\-\d+\)\:(\d+)', header).group(1))
        #cdr3_score = int(re.search('CDR3\(\d+\-\d+\)\:(\d+)', header).group(1))
        cdr1_score = int(re.search(r'CDR1\(\d+\-\d+\)\:(\d+)', header).group(1))
        cdr2_score = int(re.search(r'CDR2\(\d+\-\d+\)\:(\d+)', header).group(1))
        cdr3_score = int(re.search(r'CDR3\(\d+\-\d+\)\:(\d+)', header).group(1))
        sumscore = cdr1_score + cdr2_score + cdr3_score
        nonzero = (cdr1_score > 0) and (cdr2_score > 0) and (cdr3_score > 0)
        # we consider only if all cdr scores are nonzero and coverage > 10
        if (nonzero and concov >= 10):
            nfilt += 1
            seqsum.append({'contig': contig,
                        'chain': chain,
                        'coverage': concov,
                        'CDR1score': cdr1_score,
                        'CDR2score': cdr2_score,
                        'CDR3score': cdr3_score,
                        'Sumscore': sumscore})

	    # append to filtered seq 
            filt_seq.append(record)

# make the seq summary to a pandas dataframe
seq_df = pd.DataFrame(seqsum)

# sort the dataframe based on chain and score
seq_sort = seq_df.sort_values(by=['chain', 'Sumscore'], ascending = [True, False])

# print the dataframe to a file
out_file = 'seq_summary.csv'
seq_sort.to_csv(out_file, encoding = 'utf-8', index = False)

# write the filtered seq to a fasta file
fasta_out = pref + '_filtered.fa'
SeqIO.write(filt_seq, fasta_out, 'fasta')

print("No of filtered sequences = {}".format(nfilt))
