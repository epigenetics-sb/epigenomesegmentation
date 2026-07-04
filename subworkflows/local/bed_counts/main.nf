include { CUSTOM_BEDCOUNTS                } from '../../../modules/local/custom/bedcounts/main'
include { BEDTOOLS_MAP                    } from '../../../modules/nf-core/bedtools/map/main' 
include { CUSTOM_FILTERBED                } from '../../../modules/local/custom/filterbed/main'

workflow BED_COUNTS {

    take:
    ch_in_bedcounts
    ch_bins 

    main:
    // ---------------------------------------------------------
    // STEP 4: BED COUNTS & MAPPING
    // ---------------------------------------------------------
    CUSTOM_BEDCOUNTS(ch_in_bedcounts)

    ch_bedcounts_out = CUSTOM_BEDCOUNTS.out.countsbed
    ch_in_bedtools_map = ch_bins
        .combine(ch_bedcounts_out)
        .map { meta1, chrombin, meta2, tab -> 
            [ meta2, chrombin, tab ] 
        }
    ch_dummy_chrom_sizes = Channel.value([ [id: 'dummy'], [] ])
    
    BEDTOOLS_MAP(ch_in_bedtools_map, ch_dummy_chrom_sizes)
    CUSTOM_FILTERBED(BEDTOOLS_MAP.out.mapped)

    new_meth = CUSTOM_FILTERBED.out.meth_tab
    .map{
        meta, meth -> [meta.id, meta, meth]
        }

    new_mapped =  BEDTOOLS_MAP.out.mapped
    .map{
        meta, bed -> [meta.id, meta, bed]
    }
    emit:
    ch_meth_tab = new_meth
    ch_mapped_bed = new_mapped
}
