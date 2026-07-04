process CUSTOM_BAMCOUNTS {
    tag "${sample_id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/r-base_bioconductor-genomicranges_bioconductor-biocparallel_bioconductor-rsamtools_pruned:af94738350242789':
        'community.wave.seqera.io/library/r-base_bioconductor-genomicranges_bioconductor-biocparallel_bioconductor-rsamtools_pruned:5811f076bcdfeb97' }"

    input:
    tuple val(sample_id), val(meta), path(sheetbam), path(bam)
    tuple val(genome), path(chrom_sizes)

    output:
    tuple val(sample_id), val(meta), path("*.tab"), emit: bamcounts
    tuple val("${task.process}"), val('episegmix'), eval("episegmix --version"), topic: versions, emit: versions_episegmix

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: "-s ${params.binsize}"
    def prefix = task.ext.prefix ?: "${sheetbam.baseName}"

    """
    countsbam.sh \\
        $args \\
        -g ${genome} \\
        -c ${chrom_sizes} \\
        -@ $task.cpus \\
        -o ${prefix} \\
        -b $sheetbam
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo $args
    
    touch ${prefix}.tab
    """
}
