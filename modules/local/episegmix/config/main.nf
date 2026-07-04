process EPISEGMIX_CONFIG {
    tag "${sample_id}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'ubuntu:22.04':
        'ubuntu:22.04' }"

    input:
    tuple val(sample_id), val(meta), path(histone), val(meta2), path(meth), val(state)

    output:
    tuple val(sample_id), val(meta), path(histone), val(meta2), path(meth), val(state), path("*.yaml"), emit: yaml
    tuple val("${task.process}"), val('episegmix'), eval("episegmix --version"), topic: versions, emit: versions_episegmix

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: "-s ${state} -n ${meta2.distribution} -c ${params.chr_parameter_estimation}"
    def meth_file = meth ? "-g \"${meth instanceof Collection ? meth.join(',') : meth}\"" : '-g null'
    def histone_file = histone ? "-h \"${histone instanceof Collection ? histone.join(',') : histone}\"" : '-h null'
    def epimark = meta.epigenetic_mark 
    ? "-m \"${meta.epigenetic_mark instanceof List ? meta.epigenetic_mark.join(' ') : meta.epigenetic_mark}\"" 
    : '-m null'
    def his_dist = meta.distribution ? "-d \"${meta.distribution.join(' ')}\"" : '-d null'
    def prefix = task.ext.prefix ?: "${sample_id}"

    """
    episegmix_config.sh \\
         $args \\
         ${epimark} \\
         ${his_dist} \\
         ${meth_file} \\
         -o ${prefix}.yaml \\
         ${histone_file}
    
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${sample_id}"
    """
    echo $args
    
    touch ${prefix}.yaml
    """
}
