nextflow.enable.dsl = 2

include { FASTP }          from './modules/fastp'
include { TRUST4 }         from './modules/trust4'
include { RENUMBER_GROUP } from './modules/renumber_group'

workflow {

    /*
     * Load metadata
     * emits: (sample, group)
     */
    samples_ch =
        Channel
            .fromPath('samples.csv')
            .splitCsv(header:true)
            .map { row ->
                tuple(row.sample.trim(), row.group.trim())
            }

    /*
     * Pair FASTQs
     * emits: (sample, [R1, R2])
     */
    reads_ch =
        Channel.fromFilePairs("data/*_{1,2}.fastq.gz")

    /*
     * Attach group BEFORE any processing
     * emits: (sample, group, [R1, R2])
     */
    reads_with_group =
    reads_ch
        .join(samples_ch)
        .map { sample, reads, group ->
            tuple(sample, group, reads)
        }


    /*
     * Per-sample FASTP
     * emits: (sample, group, [fastp_R1, fastp_R2])
     */
    fastp_out = FASTP(reads_with_group)

    /*
     * Per-sample TRUST4
     * emits: (sample, group, annot.fa)
     */
    trust4_out = TRUST4(fastp_out)

    /*
     * Group annot.fa by biological group
     * emits: (group, [annot.fa, annot.fa, ...])
     */
    grouped_annots =
    trust4_out
        .groupTuple(by: 1)
        .map { samples, group, annots ->
            tuple(group, annots)
        }


    /*
     * Per-group renumbering
     */
    RENUMBER_GROUP(grouped_annots)
}
