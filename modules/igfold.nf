process IGFOLD {
  tag "${group}_${chain}"
  publishDir "${params.outdir}/igfold", mode: 'copy'

  input:
  tuple val(group), val(chain), path(riot_fa)

  output:
  tuple val(group), val(chain), path("${group}_${chain}_pdb"), emit: structures

  script:
  """
  mkdir -p ${group}_${chain}_pdb
  
  # Run IgFold for 3D structure prediction
  igfold predict \
    --input_fasta ${riot_fa} \
    --output_dir ${group}_${chain}_pdb \
    --num_models 1 \
    --num_recycles 4
  """
}
