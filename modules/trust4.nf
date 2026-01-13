process TRUST4 {

  publishDir "${params.outdir}/trust4", mode: 'copy'

  input:
  tuple val(sample), val(group), path(reads)

  output:
  tuple val(sample), val(group),
        path("${sample}/*_annot.fa")

  script:
  """
  ${projectDir}/bin/trust4.sh \
    ${reads[0]} \
    ${reads[1]} \
    ${sample} \
    ${params.organism}
  """
}
