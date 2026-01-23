process IMMUNOMATCH {
  tag "${group}"
  publishDir "${params.outdir}/immunomatch", mode: 'copy'

  input:
  tuple val(group), val(chain), path(riot_fa)

  output:
  tuple val(group), val(chain), path("${group}_${chain}_immunomatch.csv"), emit: matches

  script:
  """
  python ${projectDir}/bin/immunomatch_search.py \
    ${riot_fa} \
    ${group} \
    ${chain} \
    ${group}_${chain}_immunomatch.csv
  """
}
