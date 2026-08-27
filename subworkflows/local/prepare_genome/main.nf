include { CUSTOM_DOWNLOADCHROMSIZES } from '../../../modules/local/custom/downloadchromsizes/main'
include { CUSTOM_FILTERCHROMSIZES   } from '../../../modules/local/custom/filterchromsizes/main'
include { GENERATE_GENOME_BINS      } from '../../../modules/local/generate_genome_bins/main'

workflow PREPARE_GENOME {
    main:
    ch_versions = Channel.empty()

    // 1. CONDITIONAL: Download or use provided chromsizes
    if (!params.chromsizes) {
        // Scenario A (3 runs): No file provided, so we download it first
        CUSTOM_DOWNLOADCHROMSIZES(
            params.genome
        )
        ch_raw_chromsizes = CUSTOM_DOWNLOADCHROMSIZES.out.chromsizes
    } else {
        // Scenario B (2 runs): File is provided, skip download and convert string to a file channel
        ch_raw_chromsizes = Channel.fromPath(params.chromsizes)
    }

    // 2. FILTER: Run the filter module on whichever channel was created above
    CUSTOM_FILTERCHROMSIZES(
        ch_raw_chromsizes
    )

    // 3. BIN: Create fixed-size genomic windows from the filtered sizes
    GENERATE_GENOME_BINS(
        CUSTOM_FILTERCHROMSIZES.out.chromsizes_V2,
        params.genome,
        params.binsize
    )
    ch_versions = ch_versions.mix(GENERATE_GENOME_BINS.out.versions)

    emit:
    // Emit the filtered sizes and bins for downstream use
    chrom_sizes = CUSTOM_FILTERCHROMSIZES.out.chromsizes_V2
    bins        = GENERATE_GENOME_BINS.out.bins_file
    versions    = ch_versions
}