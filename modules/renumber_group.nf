process RENUMBER_GROUP {

  publishDir "${params.outdir}/renumbered", mode: 'copy'

  input:
  tuple val(group), path(annot_fas)

  output:
  tuple val(group),
        path("${group}_renum_annot.fa"),
        path("id_mapping_${group}.csv")

  script:
  """
  cat ${annot_fas.join(' ')} > ${group}_annot.fa
  python ${projectDir}/bin/renumber.py ${group}
  """
}
