#!/bin/bash
# script to run TRUST4 single sample for rabbit

# get sample id from argument
samp=$1

# reference files
bcr_file=/home/user/tools/TRUST4/rabbit/GRCm38_bcrtcr.fa
ref_file=/home/user/tools/TRUST4/rabbit/rabbit_IMGT+C.fa

# read files
r1_file=${samp}_RNA_SP_S10_L006_fastp_1.fastq.gz
r2_file=${samp}_RNA_SP_S10_L006_fastp_2.fastq.gz

# run TRUST4 (use -f and --ref as same file)
/home/user/tools/TRUST4/run-trust4 -1 ${r1_file} -2 ${r2_file} \
	-f ${ref_file} --ref ${ref_file} \
	-t 40 --od ${samp} -o ${samp} 
