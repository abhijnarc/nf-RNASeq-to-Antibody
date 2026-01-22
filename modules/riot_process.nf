process RIOT_PROCESS {

  publishDir "${params.outdir}/riot", mode: 'copy'
  tag "${group}_${chain}"

  input:
  tuple val(group), val(chain), path(airr_file)

  output:
  tuple val(group), val(chain), path("${group}_${chain}_riot.fa")

  script:
  """
  python ${projectDir}/bin/riot_process.py \
    ${airr_file} \
    ${group} \
    ${chain} \
    ${group}_${chain}_riot.fa
  """
}
