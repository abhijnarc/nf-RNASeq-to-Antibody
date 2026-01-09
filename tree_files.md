bcr_to_vhvl_pipeline/
├── main.nf
├── nextflow.config
├── references/ [fasta files]
│   ├── hg38_bcr.fa [Human]
│   ├── human_IMGT+C.fa [Human]
│   ├── GRCm38_bcrtcr.fa [Rabbit]
│   └── rabbit_IMGT+C.fa [Rabbit]
├── data/
│   ├── <Im_Sample>_R1_001.fastq.gz [Immunized Sequences]
│   ├── <Im_Sample>_R2_001.fastq.gz [Immunized Sequences]
│   ├── <Ct_Sample>_R1_001.fastq.gz [Control Sequences]
│   └── <Ct_Sample>_R2_001.fastq.gz [Control Sequences]
├── bin/
│   ├── fastp.sh [Input: ./data/<Sample>_fastq.gz , Output: <Sample>_fastp_[1/2].fastq.gz ] <- Both Im and Ct 
│   ├── trust4.sh [Input: <Sample>_fastp_[1/2].fastq.gz , Output: <Sample>/<Sample>_annot.fa ] <- Both Im and Ct *user input for human OR rabbit and use bcr and ref files accordingly
│   ├── process_seq.py [Input: <Sample>_annot.fa , Output: seq_summary_<Sample>.csv , <Sample>_filtered.fa ] <- Both Im and Ct
│   ├── sort_chain.py [Input: <Sample>_filtered.fa , Output: heavy_<Sample>.fa , light_<Sample>.fa] <- Both Im and Ct
│   ├── pseudo.py [Input: heavy/light_<Sample>.fa , Output: heavy/light_pseudo_<Sample>.fa ] <- Both Im and Ct
│   ├── renameid.py [Input: heavy/light_pseudo_<Ct_Sample>.fa , Output: heavy/light_renamed_<Sample>.fa ]
│   ├── mmseqs2.sh [Input: heavy/light_renamed_<Ct_Sample>.fa, heavy/light_<Im_Sample>.fa, Output: heavy/light_clusters.tsv]
|   ├── cluster_filter.py [Input: heavy/light_clusters.tsv, non_pseudo_< Output: igb_heavy/light.fa]
│   ├── igblast.sh [Input: igb_heavy/light.fa, Output: <Im_Sample>_heavy/light.airr]
│   ├── airr_filter.py [Input:<Im_Sample>_heavy/light.airr, Output: <Im_Sample>_heavy/light_filtered.airr]
│   ├── riot_succesful.py [Input: <Im_Sample>_heavy/light_filtered.airr, Output: ./VH_VL/ab{}.fa] <- Vh and VL chains in seperate fasta files
│   └── expression_sort.py [Input: ./VH_VL/ab{}.fa, <Im_Sample>_annot.fa, Output: <Im_Sample>_ranked.csv]
|
├── For Docker- Tools/Libraries/
    ├── Python v3.12
    ├── fastp  v0.24.0
    ├── TRUST4 v1.1.5
    ├── SeqIO
    ├── pandas
    ├── sys
    ├── MMseqs2 v13-45111+ds-2
    ├── igblastn v1.22.0
    └── RIOT v4.0
     

