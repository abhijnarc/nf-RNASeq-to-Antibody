process PROCESS_SEQ {

  publishDir "${params.outdir}/process_seq", mode: 'copy'

  input:
  tuple val(group),
        path(renum_fasta),
        path(id_map)

  output:
  tuple val(group),
        path("seq_summary_${group}.csv"),
        path("${group}_filtered.fa")

  script:
  """
  # File is already named <group>_renum_annot.fa
  python ${projectDir}/bin/process_seq.py ${group}
  """
}
