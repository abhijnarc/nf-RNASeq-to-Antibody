include { FASTP } from '../modules/fastp'
include { TRUST4 } from '../modules/trust4'
include { SeqIO_Rename } from '../modules/seqio/rename_cases_controls'
include { SeqIO_Filter } from '../modules/seqio/filter_bcrs'
include { SeqIO_Sort } from '../modules/seqio/sort_chains'
include { SeqIO_CDR } from '../modules/seqio/cdr_parse'
include { MMSEQS2 } from '../modules/mmseqs2'
include { IGBLAST } from '../modules/igblast'
include { RIOT } from '../modules/riot'

workflow BCR_ANALYSIS {
    take:
    samples

    main:
    cleaned = FASTP(samples)
    assembled = TRUST4(cleaned)
    renamed  = SeqIO_Rename(assembled)
    filtered = SeqIO_Filter(renamed)
    sorted   = SeqIO_Sort(filtered)
    cdrs     = SeqIO_CDR(sorted)
    clustered = MMSEQS2(cdrs)
    scanned   = IGBLAST(clustered)
    annotated = RIOT(scanned)

    emit:
    final = annotated
}
