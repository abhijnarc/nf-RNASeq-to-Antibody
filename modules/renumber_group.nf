process RENUMBER_GROUP {

  tag { group }

  publishDir "${params.outdir}/renumbered", mode: 'copy'

  input:
  tuple val(group), path(annot_fas)

  output:
  tuple val(group),
        path("${group}_renum_annot.fa"),
        path("id_mapping_${group}.csv")

  script:
  """
  ${projectDir}/bin/grouping.sh \
    ${group} \
    ${annot_fas.join(' ')}
  """
}
