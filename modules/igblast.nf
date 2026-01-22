process IGBLAST {
    tag "${group}_${chain}"
    publishDir "${params.outdir}/igblast", mode: 'copy'

    input:
    tuple val(group), val(chain), path(unique_fa)

    output:
    tuple val(group), val(chain), path("${group}_${chain}.airr"), emit: airr

    script:
    def organism = params.organism ?: 'human'
    
    if (organism == 'human') {
        """
        # Preprocess FASTA to keep only sequence ID (first word of header)
        awk '
          /^>/ { if (seq) print seq; print \$1; seq=""; next }
          { seq = seq \$0 }
          END { if (seq) print seq }
        ' ${unique_fa} > ${group}_${chain}_igb.fa

        # Run IgBLAST for human
        igblastn \
          -query ${group}_${chain}_igb.fa \
          -germline_db_V ${projectDir}/references/igb/human_V \
          -germline_db_D ${projectDir}/references/igb/human_D \
          -germline_db_J ${projectDir}/references/igb/human_J \
          -organism human \
          -ig_seqtype Ig \
          -domain_system imgt \
          -outfmt 19 \
          -out ${group}_${chain}.airr
        """
    } else if (organism == 'rabbit') {
        """
        # Preprocess FASTA to keep only sequence ID (first word of header)
        awk '
          /^>/ { if (seq) print seq; print \$1; seq=""; next }
          { seq = seq \$0 }
          END { if (seq) print seq }
        ' ${unique_fa} > ${group}_${chain}_igb.fa

        # Run IgBLAST for rabbit
        igblastn \
          -query ${group}_${chain}_igb.fa \
          -germline_db_V ${projectDir}/references/igb/rabbit_V \
          -germline_db_D ${projectDir}/references/igb/rabbit_D \
          -germline_db_J ${projectDir}/references/igb/rabbit_J \
          -organism human \
          -ig_seqtype Ig \
          -domain_system imgt \
          -outfmt 19 \
          -out ${group}_${chain}.airr
        """
    } else {
        error "Unknown organism: ${organism}. Use 'human' or 'rabbit'."
    }
}