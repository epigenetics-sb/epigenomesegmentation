process COUNTS_BAM {
    tag "$meta.id"
    label 'process_high'


    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/r-base_bioconductor-genomicranges_bioconductor-biocparallel_bioconductor-rsamtools_pruned:af94738350242789':
        'community.wave.seqera.io/library/r-base_bioconductor-genomicranges_bioconductor-biocparallel_bioconductor-rsamtools_pruned:5811f076bcdfeb97&platform=linux/amd64' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    //               by copying the line below and replacing the current tool with the extra tool(s)
    tuple val("${task.process}"), val('counts'), eval("counts --version"), topic: versions, emit: versions_counts

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    """
    counts \\
        $args \\
        -@ $task.cpus \\
        -o ${prefix}.bam \\
        $bam
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/624977dfaf562211e68a8a868ca80acc8461f1ac/modules/nf-core/cutadapt/main.nf#L34-L46
    //               Complex example: https://github.com/nf-core/modules/blob/88d43dad73a675e66bff49ebb57fe657a5909018/modules/nf-core/bedtools/split/main.nf#L32-L43
    //               - The definition of args `def args = task.ext.args ?: ''` above.
    //               - The use of the variable in the script `echo $args ` below.
    """
    echo $args
    
    touch ${prefix}.bam
    """
}
