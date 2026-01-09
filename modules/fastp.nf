process FASTP {

  tag "$sample"

  input:
  tuple val(sample), path(reads)

  output:
  tuple val(sample),
        path("${sample}_fastp_1.fastq.gz"),
        path("${sample}_fastp_2.fastq.gz"),
        path("${sample}_fastp.html")

  script:
  """
   ${projectDir}/bin/fastp_single.sh ${reads[0]} ${reads[1]} ${sample}
  """
}
