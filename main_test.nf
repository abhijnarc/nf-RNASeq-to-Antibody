include { FASTP } from './modules/fastp'

workflow {

  reads_ch =
    Channel.fromFilePairs("data/*_{1,2}.fastq.gz")

  FASTP(reads_ch)
}
