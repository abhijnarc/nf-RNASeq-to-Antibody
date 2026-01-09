#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
Pipeline based on your tree:
- fastp.sh -> trust4.sh -> process_seq.py -> sort_chain.py -> pseudo.py
- renameid.py applied to control pseudo outputs
- mmseqs2.sh compares control renamed with immunized fasta(s)
- cluster_filter.py -> igblast.sh -> airr_filter.py -> riot_succesful.py -> expression_sort.py
*/

params.outdir = params.outdir ?: 'results'
params.reads = params.reads ?: 'data/*_R1_001.fastq.gz'
params.control_regex = params.control_regex ?: '(?i)(Ct|CT|control|Ctl)'
params.immunized_regex = params.immunized_regex ?: '(?i)(Im|IM|immunized|Immunized)'
params.species = params.species ?: 'human'          // pass 'rabbit' if needed for TRUST4
params.container = params.container ?: ''           // set when running with --profile docker
params.refs = params.refs ?: 'references'           // folder with reference fasta files

// -------------- sample channel (paired fastqs) --------------
Channel.fromFilePairs(params.reads, flat:false)
    .map { pair -> 
        // pair => [ sample_id : [r1,r2] ] as map; convert to tuple: (sample_id, r1, r2)
        def sample = pair.key
        def r1 = pair.value[0]
        def r2 = pair.value[1]
        tuple(sample, r1, r2)
    }
    .set { samples_ch }


// ---------- Helper function to detect control / immunized ----------
def is_control = { id -> id ==~ /${params.control_regex}/ }
def is_immunized = { id -> id ==~ /${params.immunized_regex}/ }

// --------------- 1) FASTP (preprocess) ----------------
process FASTP {
    tag { sample_id }
    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    tuple val(sample_id), path("${sample_id}_fastp_R1.fastq.gz"), path("${sample_id}_fastp_R2.fastq.gz")

    container params.container ?: null

    script:
    """
    mkdir -p work
    ./bin/fastp.sh ${read1} ${read2} ./
    # Expect outputs: ${sample_id}_fastp_R1.fastq.gz and ${sample_id}_fastp_R2.fastq.gz
    """
}

// --------------- 2) TRUST4 (annotation) ----------------
process TRUST4 {
    tag { sample_id }
    publishDir "${params.outdir}/trust4", mode: 'copy'

    input:
    tuple val(sample_id), path(fastp1), path(fastp2)

    output:
    tuple val(sample_id), path("${sample_id}/${sample_id}_annot.fa")

    // pass params.species and refs folder in env or args
    container params.container ?: null

    script:
    """
    mkdir -p ${sample_id}
    ./bin/trust4.sh ${fastp1} ${fastp2} ${sample_id} ${params.refs} ${params.species}
    # expect ${sample_id}/${sample_id}_annot.fa
    """
}

// --------------- 3) process_seq.py ----------------
process PROCESS_SEQ {
    tag { sample_id }
    publishDir "${params.outdir}/process_seq", mode: 'copy'

    input:
    tuple val(sample_id), path(annot_fa)

    output:
    tuple val(sample_id), path("seq_summary_${sample_id}.csv"), path("${sample_id}_filtered.fa")

    container params.container ?: null

    script:
    """
    ./bin/process_seq.py ${annot_fa} ./ || exit 1
    # expected outputs: seq_summary_${sample_id}.csv and ${sample_id}_filtered.fa
    """
}

// --------------- 4) sort_chain.py ----------------
process SORT_CHAIN {
    tag { sample_id }
    publishDir "${params.outdir}/sort_chain", mode: 'copy'

    input:
    tuple val(sample_id), path(filtered_fa)

    output:
    tuple val(sample_id), path("heavy_${sample_id}.fa"), path("light_${sample_id}.fa")

    container params.container ?: null

    script:
    """
    ./bin/sort_chain.py ${filtered_fa} ./ || exit 1
    # expect heavy_${sample_id}.fa and light_${sample_id}.fa
    """
}

// --------------- 5) pseudo.py ----------------
process PSEUDO {
    tag { sample_id }
    publishDir "${params.outdir}/pseudo", mode: 'copy'

    input:
    tuple val(sample_id), path(heavy_fa), path(light_fa)

    output:
    tuple val(sample_id), path("heavy_pseudo_${sample_id}.fa"), path("light_pseudo_${sample_id}.fa")

    container params.container ?: null

    script:
    """
    ./bin/pseudo.py heavy_${sample_id}.fa ./ || exit 1
    ./bin/pseudo.py light_${sample_id}.fa ./ || exit 1
    """
}

// --------------- 6) renameid.py (control only) ----------------
process RENAMEID {
    tag { sample_id }
    publishDir "${params.outdir}/renameid", mode: 'copy'

    input:
    tuple val(sample_id), path(heavy_pseudo), path(light_pseudo)

    output:
    tuple val(sample_id), path("heavy_renamed_${sample_id}.fa"), path("light_renamed_${sample_id}.fa")

    container params.container ?: null

    when:
    // only run rename on control samples (but will run for any sample if your regex matches)
    is_control(sample_id)

    script:
    """
    ./bin/renameid.py ${heavy_pseudo} ./ || exit 1
    ./bin/renameid.py ${light_pseudo} ./ || exit 1
    # expect heavy_renamed_${sample_id}.fa & light_renamed_${sample_id}.fa
    """
}

// --------------- Collect channels for control vs immunized ----------------
// After PSEUDO we will split into control vs immunized
// Create a stream of tuples: (sample_id, heavy_pseudo, light_pseudo)
workflow {
    samples_ch
        | FASTP
        | TRUST4
        | PROCESS_SEQ
        | SORT_CHAIN
        | PSEUDO
        .set { pseudo_ch }    // pseudo_ch emits: tuple(sample_id, heavy_pseudo_X.fa, light_pseudo_X.fa)
}

// Create two channels by filtering sample_id
pseudo_ch
    .filter { t -> t[0] ==~ /${params.control_regex}/ }
    .set { control_pseudo_ch }

pseudo_ch
    .filter { t -> t[0] ==~ /${params.immunized_regex}/ }
    .set { immunized_pseudo_ch }

// Run renameid on control pseudo outputs (renameid uses control pseudo file paths)
control_pseudo_ch
    | RENAMEID
    .set { control_renamed_ch }  // emits tuple(sample_id, heavy_renamed, light_renamed)

// For immunized we don't rename; just create channels with their heavy/light pseudo files labelled
immunized_pseudo_ch
    .map { sample_id, heavy_p, light_p -> tuple(sample_id, heavy_p, light_p) }
    .set { immunized_pseudo_keep_ch }

// --------------- 7) Merge immunized files (one file each chain) ---------------
process MERGE_IM {
    tag "merge_im"
    publishDir "${params.outdir}/merged_immunized", mode: 'copy'

    input:
    set val(chain_type), path(list_of_files)

    output:
    path "merged_${chain_type}_immunized.fa"

    container params.container ?: null

    script:
    """
    cat ${list_of_files.join(' ')} > merged_${chain_type}_immunized.fa
    """
}

// create channel of heavy immunized file paths and light immunized file paths
immunized_pseudo_keep_ch
    .map { id, heavy, light -> heavy }
    .collect()
    .map { files -> tuple('heavy', files) }
    .set { im_heavy_list_ch }

immunized_pseudo_keep_ch
    .map { id, heavy, light -> light }
    .collect()
    .map { files -> tuple('light', files) }
    .set { im_light_list_ch }

// Merge them
MERGE_IM(in: im_heavy_list_ch)
MERGE_IM(in: im_light_list_ch)

// --------------- 8) MMSEQS2 (compareControlVsImmunized) ---------------
process MMSEQS {
    tag "mmseqs"
    publishDir "${params.outdir}/mmseqs2", mode: 'copy'

    input:
    tuple val(sample_id), path(control_heavy), path(control_light)    // expects single control sample
    path merged_heavy_im
    path merged_light_im

    output:
    path "heavy_clusters.tsv"
    path "light_clusters.tsv"

    container params.container ?: null

    script:
    """
    ./bin/mmseqs2.sh ${control_heavy} ${control_light} ${merged_heavy_im} ${merged_light_im} ./
    # expect heavy_clusters.tsv and light_clusters.tsv
    """
}

// We assume single control (if multiple, pick first). Collect a single control renamed pair:
control_renamed_ch
    .take(1)
    .set { one_control_ch }

// Wait for merged immunized files before running mmseqs
one_control_ch
    .combine( MERGE_IM.out.filter{ it.name =~ /merged_heavy_immunized.fa/ }.first() , MERGE_IM.out.filter{ it.name =~ /merged_light_immunized.fa/ }.first() )
    .map { ctrl_tuple, heavy_merged, light_merged -> tuple(ctrl_tuple[0], ctrl_tuple[1], ctrl_tuple[2], heavy_merged, light_merged) }
    .set { mmseqs_input_ch }

// connect to MMSEQS (unpack tuple)
mmseqs_input_ch.map { sample_id, control_heavy, control_light, merged_heavy, merged_light ->
    tuple(sample_id, control_heavy, control_light, merged_heavy, merged_light)
} | MMSEQS

// --------------- 9) cluster_filter.py -> igblast -> airr_filter -> riot -> expression ---------------

// Cluster filter takes clusters TSV and non-pseudo (?) input -> produces igb fasta. I will assume it consumes heavy_clusters.tsv/light_clusters.tsv and produces igb_heavy.fa & igb_light.fa
process CLUSTER_FILTER {
    tag "cluster_filter"
    publishDir "${params.outdir}/cluster_filter", mode: 'copy'

    input:
    path heavy_clusters
    path light_clusters

    output:
    path "igb_heavy.fa"
    path "igb_light.fa"

    container params.container ?: null

    script:
    """
    ./bin/cluster_filter.py ${heavy_clusters} ${light_clusters} ./ || exit 1
    """
}

MMSEQS.out
    .map { -> tuple(it.filter{ it.name == 'heavy_clusters.tsv' }[0], it.filter{ it.name == 'light_clusters.tsv' }[0]) }
    .set { clusters_pair_ch }

clusters_pair_ch | CLUSTER_FILTER
CLUSTER_FILTER.out.set { igb_fa_ch }    // emits igb_heavy.fa and igb_light.fa

// IGBLAST (assume produces AIRR .airr files under names <Sample>_heavy.airr etc.)
process IGBLAST {
    tag "igblast"
    publishDir "${params.outdir}/igblast", mode: 'copy'

    input:
    path igb_fa

    output:
    path "*.airr"

    container params.container ?: null

    script:
    """
    ./bin/igblast.sh ${igb_fa} ./ || exit 1
    """
}

igb_fa_ch
    .flatMap { paths -> paths }    // two files
    .map { p -> p } 
    | IGBLAST
    .set { airr_ch }

// AIRR filter
process AIRR_FILTER {
    tag "airr_filter"
    publishDir "${params.outdir}/airr_filter", mode: 'copy'

    input:
    path airr_file

    output:
    path "*_filtered.airr"

    container params.container ?: null

    script:
    """
    ./bin/airr_filter.py ${airr_file} ./ || exit 1
    """
}

airr_ch | AIRR_FILTER | set { filtered_airr_ch }

// RIOT -> produce VH_VL/ab{}.fa fasta files
process RIOT {
    tag "riot"
    publishDir "${params.outdir}/riot", mode: 'copy'

    input:
    path filtered_airr

    output:
    path "VH_VL/*.fa"

    container params.container ?: null

    script:
    """
    mkdir -p VH_VL
    ./bin/riot_succesful.py ${filtered_airr} VH_VL/ || exit 1
    """
}

filtered_airr_ch | RIOT | set { vhvl_ch }

// EXPRESSION SORT
process EXPRESSION_SORT {
    tag "expression_sort"
    publishDir "${params.outdir}/expression", mode: 'copy'

    input:
    path vhvl_fa
    path annot_fa     // corresponding immunized annotation used for ranking (we'll pass the first immunized annot for now)

    output:
    path "*_ranked.csv"

    container params.container ?: null

    script:
    """
    ./bin/expression_sort.py ${vhvl_fa} ${annot_fa} ./ || exit 1
    """
}

// For expression sorting we need pairs of VH_VL fasta and corresponding immunized annotation.
// Simplest approach: pair each VH_VL produced with the first immunized annotation file (if multiple).
immunized_annot_ch = Channel.fromPath("results/trust4/*/*_annot.fa").first()
vhvl_ch
    .flatMap { it -> Channel.fromPath(it + "/*") }  // passthru
    .map { vhfile -> tuple(vhfile, immunized_annot_ch) }
    | EXPRESSION_SORT
