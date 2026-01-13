process TRUST4 {

  publishDir "${params.outdir}/trust4", mode: 'copy'

  input:
  tuple val(sample), val(group), path(reads)

  output:
  tuple val(sample), val(group),
        path("${sample}/${sample}_annot_with_sample.fa")

  script:
  """
  # Run TRUST4 (unchanged)
  ${projectDir}/bin/trust4.sh \
    ${reads[0]} \
    ${reads[1]} \
    ${sample} \
    ${params.organism}

  # Inject sample ID into FASTA headers
  python ${projectDir}/bin/inject_sampleid.py \
    ${sample} \
    ${sample}/*_annot.fa \
    ${sample}/${sample}_annot_with_sample.fa
  """
}
