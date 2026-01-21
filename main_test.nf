nextflow.enable.dsl = 2

include { FASTP }              from './modules/fastp'
include { TRUST4 }             from './modules/trust4'
include { RENUMBER_GROUP }     from './modules/renumber_group'
include { PROCESS_SEQ }        from './modules/process_seq'
include { SPLIT_BY_CHAIN }     from './modules/split_by_chain'
include { CDR_PSEUDO }         from './modules/pseudo'
include { MMSEQS_CLUSTER }     from './modules/mmseqs_cluster'
include { FILTER_BY_CLUSTER }  from './modules/cluster_filter'

workflow {

    /*
     * -------------------------------
     * 1. Sample metadata
     * -------------------------------
     */
    samples_ch =
        Channel
            .fromPath('samples.csv')
            .splitCsv(header: true)
            .map { row ->
                tuple(row.sample.trim(), row.group.trim())
            }
    // (sample, group)

    /*
     * -------------------------------
     * 2. FASTQ pairing
     * -------------------------------
     */
    reads_ch =
        Channel.fromFilePairs('data/*_{1,2}.fastq.gz')
    // (sample, [R1, R2])

    reads_with_group =
        reads_ch
            .join(samples_ch)
            .map { sample, reads, group ->
                tuple(sample, group, reads)
            }
    // (sample, group, [R1, R2])

    /*
     * -------------------------------
     * 3. Per-sample processing
     * -------------------------------
     */
    fastp_out  = FASTP(reads_with_group)
    trust4_out = TRUST4(fastp_out)
    // (sample, group, annot.fa)

    /*
     * -------------------------------
     * 4. Group FASTAs
     * -------------------------------
     */
    grouped_fastas =
        trust4_out
            .groupTuple(by: 1)
            .map { samples, group, annots ->
                tuple(group, annots)
            }
    // (group, [annot.fa, ...])

    /*
     * -------------------------------
     * 5. Renumber per group
     * -------------------------------
     */
    renum_out = RENUMBER_GROUP(grouped_fastas)
    // (group, <group>_renum_annot.fa, id_mapping.csv)

    /*
     * -------------------------------
     * 6. Group-level sequence QC
     * -------------------------------
     */
    process_seq_out = PROCESS_SEQ(renum_out)
    // (group, seq_summary.csv, group_filtered.fa)

    /*
     * -------------------------------
     * 7. Split into heavy / light
     * -------------------------------
     */
    split_out = SPLIT_BY_CHAIN(process_seq_out)
    // (group, heavy.fa, light.fa)

 /*
 * -------------------------------
 * 8. Generate pseudo-sequences
 * -------------------------------
 */
cdr_inputs =
    split_out
        .flatMap { group, heavy, light -> 
            [heavy, light]
        }

CDR_PSEUDO(cdr_inputs)
    .set { pseudo_out }
// emits files like CTL_heavy_pseudo.fa, CTL_light_pseudo.fa

/*
 * -------------------------------
 * 9. MMSeqs2 clustering (cross-group)
 * -------------------------------
 */
// Collect all heavy and light pseudo files
heavy_pseudo_all = pseudo_out.filter { file -> file.name.contains('_heavy_pseudo') }.collect()
light_pseudo_all = pseudo_out.filter { file -> file.name.contains('_light_pseudo') }.collect()

// Create a single-element channel containing the collected files
cluster_files_ch = channel.of([heavy_pseudo_all, light_pseudo_all])

MMSEQS_CLUSTER(heavy_pseudo_all, light_pseudo_all)

/*
 * -------------------------------
 * 10. Cluster filtering (cross-group comparison)
 * -------------------------------
 */
heavy_filter_inputs =
    split_out
        .map { group, heavy_fa, light_fa ->
            tuple(group, 'heavy', heavy_fa)
        }

light_filter_inputs =
    split_out
        .map { group, heavy_fa, light_fa ->
            tuple(group, 'light', light_fa)
        }

// Get cluster file paths from MMSEQS_CLUSTER output
h_clusters_file = MMSEQS_CLUSTER.out[0]
l_clusters_file = MMSEQS_CLUSTER.out[1]

// Combine with cluster outputs
heavy_with_clusters = 
    heavy_filter_inputs.combine(h_clusters_file)
        .map { group, chain, fa, h_clusters ->
            tuple(group, chain, h_clusters, fa)
        }

light_with_clusters = 
    light_filter_inputs.combine(l_clusters_file)
        .map { group, chain, fa, l_clusters ->
            tuple(group, chain, l_clusters, fa)
        }

FILTER_BY_CLUSTER(
    heavy_with_clusters.mix(light_with_clusters)
)
}