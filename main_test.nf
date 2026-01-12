include { FASTP }  from './modules/fastp'
include { TRUST4 } from './modules/trust4'

workflow {

  reads_ch =
    Channel.fromFilePairs("data/*_{1,2}.fastq.gz")

  fastp_out = FASTP(reads_ch)
  TRUST4(fastp_out)
}
