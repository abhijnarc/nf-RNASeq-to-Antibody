process SPLIT_BY_CHAIN {

  publishDir "${params.outdir}/split_by_chain", mode: 'copy'

  input:
  tuple val(group),
        path(seq_summary),
        path(filtered_fa)

  output:
  tuple val(group),
        path("${group}_heavy.fa"),
        path("${group}_light.fa")

  script:
  """
  # Files already exist with correct names:
  #   seq_summary_<group>.csv
  #   <group>_filtered.fa
  python ${projectDir}/bin/split_by_chain.py ${group}
  """
}
