process CUSTOM_FILTERCHROMSIZES {
    tag "${chromsizes}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:22.04':
        'ubuntu:22.04' }"

    input:
    path chromsizes

    output:
    path "${chromsizes}.V2", emit: chromsizes_V2
    tuple val("${task.process}"), val('custom'), eval("awk --version | cut -f 3 -d \" \" "), topic: versions, emit: versions_awk
    tuple val("${task.process}"), val('sort'), eval("sort --version | head -n 1 | awk '{print \$NF}'"), topic: versions, emit: versions_sort

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '-v OFS="\\t" \'$1 ~ /^chr([1-9][0-9]?|X|Y)$/ { sub(/^chr/, "", $1); print}\''
    def prefix   = task.ext.prefix ?: "${chromsizes}"

    """
    awk \\
        $args \\
        ${chromsizes} \\
        | sort -k1,1V  > ${prefix}.V2
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix   = task.ext.prefix ?: "${chromsizes}"

    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/624977dfaf562211e68a8a868ca80acc8461f1ac/modules/nf-core/cutadapt/main.nf#L34-L46
    //               Complex example: https://github.com/nf-core/modules/blob/88d43dad73a675e66bff49ebb57fe657a5909018/modules/nf-core/bedtools/split/main.nf#L32-L43
    // TODO nf-core: If the module doesn't use arguments ($args), you SHOULD remove:
    //               - The definition of args `def args = task.ext.args ?: ''` above.
    //               - The use of the variable in the script `echo $args ` below.
    """
    echo $args

    touch ${prefix}_V2
    """
}
