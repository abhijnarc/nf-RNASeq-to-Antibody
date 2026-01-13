process FASTP {

  publishDir "${params.outdir}/fastp", mode: 'copy'

  input:
  tuple val(sample), val(group), path(reads)

  output:
  tuple val(sample), val(group),
        path("${sample}_fastp_*.fastq.gz")

  script:
  """
  ${projectDir}/bin/fastp_single.sh \
    ${reads[0]} \
    ${reads[1]} \
    ${sample}
  """
}
