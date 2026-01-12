process TRUST4 {

  tag "$sample"

  publishDir "${params.outdir}/trust4", mode: 'copy'

  input:
  tuple val(sample), path(reads)

  output:
  tuple val(sample),
        path("${sample}/*")

  script:
  """
  ${projectDir}/bin/trust4.sh \
    ${reads[0]} \
    ${reads[1]} \
    ${sample} \
    ${params.organism}
  """
}
