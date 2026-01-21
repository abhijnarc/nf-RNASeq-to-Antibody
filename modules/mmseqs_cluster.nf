process MMSEQS_CLUSTER {

  publishDir "${params.outdir}/mmseqs", mode: 'copy'

  input:
  path heavy_pseudo_list   // List of all heavy pseudo files
  path light_pseudo_list   // List of all light pseudo files

  output:
  path "all_groups_Hclusters.tsv"
  path "all_groups_Lclusters.tsv"

  script:
  """
  # Concatenate all heavy chain pseudo files
  cat ${heavy_pseudo_list.join(' ')} > combined_heavy.fa
  
  # Concatenate all light chain pseudo files
  cat ${light_pseudo_list.join(' ')} > combined_light.fa

  # Cluster heavy chains across all groups
  mmseqs createdb combined_heavy.fa HcombinedDB
  mmseqs cluster HcombinedDB HclusteredDB tmp_H --min-seq-id 0.9 --cov-mode 0
  mmseqs createtsv HcombinedDB HcombinedDB HclusteredDB all_groups_Hclusters.tsv

  # Cluster light chains across all groups
  mmseqs createdb combined_light.fa LcombinedDB
  mmseqs cluster LcombinedDB LclusteredDB tmp_L --min-seq-id 0.9 --cov-mode 0
  mmseqs createtsv LcombinedDB LcombinedDB LclusteredDB all_groups_Lclusters.tsv
  """
}