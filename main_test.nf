nextflow.enable.dsl = 2

include { FASTP }          from './modules/fastp'
include { TRUST4 }         from './modules/trust4'
include { RENUMBER_GROUP } from './modules/renumber_group'
include { PROCESS_SEQ }    from './modules/process_seq'
include { SPLIT_BY_CHAIN } from './modules/split_by_chain'

workflow {

    /*
     * -------------------------------
     * Metadata
     * -------------------------------
     */
    samples_ch =
        Channel
            .fromPath('samples.csv')
            .splitCsv(header: true)
            .map { row ->
                tuple(row.sample.trim(), row.group.trim())
            }

    /*
     * -------------------------------
     * FASTQ pairing
     * -------------------------------
     */
    reads_ch =
        Channel.fromFilePairs("data/*_{1,2}.fastq.gz")

    reads_with_group =
        reads_ch
            .join(samples_ch)
            .map { sample, reads, group ->
                tuple(sample, group, reads)
            }

    /*
     * -------------------------------
     * Per-sample processing
     * -------------------------------
     */
    fastp_out  = FASTP(reads_with_group)
    trust4_out = TRUST4(fastp_out)

    /*
     * -------------------------------
     * Group concatenation
     * -------------------------------
     */
    grouped_fastas =
        trust4_out
            .groupTuple(by: 1)
            .map { samples, group, annots ->
                tuple(group, annots)
            }

    /*
     * -------------------------------
     * RENUMBER FIRST (final IDs)
     * -------------------------------
     */
    renum_out = RENUMBER_GROUP(grouped_fastas)
    // emits: (group, <group>_renum_annot.fa, id_mapping_<group>.csv)

    /*
     * -------------------------------
     * Group-level sequence QC
     * -------------------------------
     */
    process_seq_out = PROCESS_SEQ(renum_out)
    // emits: (group, seq_summary_<group>.csv, <group>_filtered.fa)

    /*
     * -------------------------------
     * Split by heavy / light
     * -------------------------------
     */
    SPLIT_BY_CHAIN(process_seq_out)
}
