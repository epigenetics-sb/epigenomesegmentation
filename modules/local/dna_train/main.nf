process DNA_TRAIN {
    tag "Train: ${meta.id}"
    label 'process_high'
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'aaryanjaitly/episegmix:new_plots' :
        'aaryanjaitly/episegmix:new_plots' }"

    beforeScript """
        if [[ "\$(uname)" == "Darwin" ]]; then
            export PATH="\$PATH:${projectDir}/bin/src:${projectDir}/bin/HMM/pre-built/mac"
        else
            export PATH="\$PATH:${projectDir}/bin/src:${projectDir}/bin/HMM/pre-built/linux"
        fi
    """

    input:
    tuple val(meta), path(config), path(train_counts), path(train_regions)

    output:
    tuple val(meta), path("*.model.json"), emit: model
    path "*.log"                         , emit: log
    path "versions.yml"                  , emit: versions

    script:
    """
    set -euo pipefail

    # 1. INITIALIZE HMM
    init_HMM.py \\
        -e "${train_counts}" \\
        -m "${config}" \\
        -j "${meta.id}.preinit.json"

    add_topology_to_init.py  \\
        --input "${meta.id}.preinit.json" \\
        --output "${meta.id}.init.json"

    # 2. RUN TOPOLOGY HMM
    TopologyHMM \\
        -t -n ${params.adjustment} \\
        -m "${meta.id}.init.json" \\
        -o "${meta.id}.model.json" \\
        -x "${train_counts}" \\
        -r "${train_regions}" \\
        -i "${params.iter}" -e "${params.epsilon}" \\
        -p ${task.cpus} \\
        &> "${meta.id}.log"

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    python: \$(python --version | awk '{print \$2}')
END_VERSIONS
    """

    stub:
    """
    touch "${meta.id}.model.json"
    touch "${meta.id}.log"

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    python: \$(python --version | awk '{print \$2}')
END_VERSIONS
    """
}
