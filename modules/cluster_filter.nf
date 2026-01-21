process FILTER_BY_CLUSTER {

  publishDir "${params.outdir}/cluster_filtered", mode: 'copy'

  input:
  tuple val(group), val(chain), path(cluster_tsv), path(group_fasta)

  output:
  path "${group}_${chain}_unique.fa"

  script:
  """
  python ${projectDir}/bin/cluster_filter.py \
    ${cluster_tsv} \
    ${group} \
    ${group_fasta} \
    ${group}_${chain}_unique.fa
  """
}
