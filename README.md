# RNASeq-to-Antibody (VH/VL → Pairing → Modelling)

A reproducible **Nextflow DSL2 pipeline** for reconstructing antibody repertoires from RNA-seq data, filtering viable VH/VL chains, pairing compatible heavy–light chains, and (optionally) modelling structures.

---

## Overview

This pipeline takes **paired-end RNA-seq FASTQ files** and produces:

- high-confidence **VH and VL sequences**
- filtered, non-redundant repertoires
- group-aware outputs (e.g. disease vs control)
- optional **VH–VL pairing** using ImmunoMatch
- optional **structure modelling** using IGFold

The pipeline is designed to be:
- modular
- group-agnostic
- reproducible
- extensible

---

## Pipeline stages

### 1. Read preprocessing
- Quality control and trimming (`fastp`)
- Paired-end read handling

### 2. Immune repertoire reconstruction
- BCR/TCR reconstruction using **TRUST4**
- Per-sample assembly

### 3. Group-level processing
- Group-wise concatenation
- Continuous renumbering with ID mapping
- Coverage and CDR-based filtering

### 4. Chain separation
- Separation into **VH (heavy)** and **VL (light)** FASTA files

### 5. Pseudo-sequence generation
- Extraction and concatenation of CDRs
- Used for clustering and similarity filtering

### 6. Similarity filtering
- MMseqs2 clustering
- Removal of group-specific sequences similar to other groups

### 7. Final outputs
- High-confidence VH and VL FASTAs per group  
  (e.g. `CAD_heavy.fa`, `CAD_light.fa`)

---

## Optional downstream steps

### VH–VL pairing (ImmunoMatch)
- Cartesian pairing of VH and VL repertoires per group
- Batch scoring using ImmunoMatch
- Output: ranked VH–VL compatibility table (`pairs.tsv`)

### Structure modelling (IGFold)
- **NB mode**: nanobody modelling from VH only
- **AB mode**: antibody modelling from paired VH–VL
- Fast, antibody-specific structure prediction
- No external databases required

These steps are designed as **optional workflow branches** and can be enabled later without changing upstream logic.

---

## Input requirements

### FASTQ files
Paired-end reads named as:
data/
├── SAMPLE1_1.fastq.gz
├── SAMPLE1_2.fastq.gz
├── SAMPLE2_1.fastq.gz
└── SAMPLE2_2.fastq.gz

### Sample metadata (`samples.csv`)
A CSV file mapping samples to groups:

```csv
sample,group
SAMPLE1,CAD
SAMPLE2,CTL

Output structure (simplified)
results/
├── fastp/
├── trust4/
├── renumber/
├── process_seq/
├── split_chain/
├── pseudo/
├── mmseqs/
├── cluster_filtered/
│   ├── CAD_heavy.fa
│   ├── CAD_light.fa
│   ├── CTL_heavy.fa
│   └── CTL_light.fa


Optional downstream outputs:

results/
├── immunomatch/
│   └── CAD_pairs.tsv
├── igfold/
│   ├── nanobodies/
│   └── antibodies/

Running the pipeline
Basic run (up to VH/VL repertoires)
nextflow run main.nf

Resume after interruption
nextflow run main.nf -resume

Dependencies

Nextflow ≥ 23.x

Java ≥ 11

External tools are wrapped as pipeline modules and will be containerised.

Containerisation

The pipeline is designed to be fully containerised using:

Docker (local runs)

Singularity / Apptainer (HPC runs)

Planned containers include:

core tools (fastp, TRUST4, MMseqs2)

ImmunoMatch

IGFold

This allows users to clone the repository and run the pipeline without manual installation.

Design principles

Workflow orchestration only in Nextflow

Scientific logic implemented in standalone tools/scripts

Group-aware processing at every stage

Deterministic, reproducible outputs

Clear separation between pairing and modelling

Project status

Core VH/VL pipeline: complete

MMseqs-based filtering: complete

ImmunoMatch integration: in progress

IGFold modelling: planned

Citation

If you use this pipeline, please cite:

TRUST4

MMseqs2

ImmunoMatch

IGFold

(Full citation list to be added.)

