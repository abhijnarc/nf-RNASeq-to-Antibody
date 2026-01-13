nextflow.enable.dsl = 2

include { FASTP }          from './modules/fastp'
include { TRUST4 }         from './modules/trust4'
include { RENUMBER_GROUP } from './modules/renumber_group'

workflow {

    /*
     * ----------------------------
     * 1. Read sample → group map
     * ----------------------------
     */
    samples_ch =
        Channel
            .fromPath('samples.csv')
            .splitCsv(header: true)
            .map { row ->
                tuple(row.sample, row.group)
            }

    /*
     * ----------------------------
     * 2. Raw FASTQ pairing
     * ----------------------------
     */
    reads_ch =
        Channel.fromFilePairs("data/*_{1,2}.fastq.gz")

    /*
     * ----------------------------
     * 3. Per-sample processing
     * ----------------------------
     */
    fastp_out  = FASTP(reads_ch)
    trust4_out = TRUST4(fastp_out)
    // trust4_out: (sample, annot.fa)

    /*
     * ----------------------------
     * 4. Attach group information
     * ----------------------------
     */
    //trust4_with_group =
        //trust4_out
            //.join(samples_ch)
            //.map { sample, annot_fa, group ->
                //tuple(group, sample, annot_fa)
            //}
    // (group, sample, annot.fa)
    trust4_with_group =
      trust4_out
          .join(samples_ch)
          .map { sample, values ->
              def annot_fa = values[0]
              def group    = values[1]
              tuple(group, sample, annot_fa)
          }

    /*
     * ----------------------------
     * 5. Group annot.fa by group
     * ----------------------------
     */
    grouped_annots =
        trust4_with_group
            .groupTuple(by: 0)
            .map { group, records ->
                tuple(
                    group,
                    records.collect { it[2] }   // list of annot.fa paths
                )
            }
    // (group, [annot1.fa, annot2.fa, ...])

    /*
     * ----------------------------
     * 6. Per-group renumbering
     * ----------------------------
     */
    RENUMBER_GROUP(grouped_annots)
}
