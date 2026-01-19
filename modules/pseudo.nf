process CDR_PSEUDO {

  publishDir "${params.outdir}/cdr_pseudo", mode: 'copy'

  input:
  path(fasta)

  output:
  path("${fasta.simpleName}_pseudo.fa")

  script:
  """
  python ${projectDir}/bin/pseudo.py ${fasta.simpleName}
  """
}
