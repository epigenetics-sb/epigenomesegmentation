include { EPISEGMIX_LDMTRAIN             } from '../../../modules/local/episegmix/ldmtrain/'
include { EPISEGMIX_BESTDISTRIBUTION      } from '../../../modules/local/episegmix/bestdistribution/'

workflow EPISEGMIX_FITTING {

    take:
    ch_train_counts

    main:
    EPISEGMIX_LDMTRAIN(ch_train_counts)
    ch_ldmtrain_log = EPISEGMIX_LDMTRAIN.out.log

    ch_in_bestfit = ch_ldmtrain_log.groupTuple()
    ch_input = Channel.of(params.input)

    EPISEGMIX_BESTDISTRIBUTION(ch_in_bestfit, ch_input)

    emit:
    EPISEGMIX_BESTDISTRIBUTION.out.samplesheet
}
