process FASTP {
    tag "$sample_id"
    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_fastp_1.fastq.gz")
    tuple val(sample_id), path("${sample_id}_fastp_2.fastq.gz")
    path "${sample_id}_fastp.html"

    script:
    """
    fastp \
      --in1 ${reads[0]} \
      --in2 ${reads[1]} \
      --out1 ${sample_id}_fastp_1.fastq.gz \
      --out2 ${sample_id}_fastp_2.fastq.gz \
      --qualified_quality_phred 30 \
      --detect_adapter_for_pe \
      --correction \
      --trim_tail1=1 \
      --cut_tail \
      --cut_window_size=4 \
      --cut_mean_quality=30 \
      --length_required=50 \
      --html ${sample_id}_fastp.html
    """
}
