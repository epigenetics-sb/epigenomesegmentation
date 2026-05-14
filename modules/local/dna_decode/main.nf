process DNA_DECODE {
    tag "Decode: ${meta.id}"
    label 'process_medium'
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://aaryanjaitly/episegmix:new_plots' :
        'aaryanjaitly/episegmix:new_plots' }"

    beforeScript """
        if [[ "\$(uname)" == "Darwin" ]]; then
            export PATH="\$PATH:${projectDir}/bin/src:${projectDir}/bin/HMM/pre-built/mac"
        else
            export PATH="\$PATH:${projectDir}/bin/src:${projectDir}/bin/HMM/pre-built/linux"
        fi
    """

    input:
    tuple val(meta), path(config), path(model), path(counts), path(regions)

    output:
    tuple val(meta), path("segmentation/${meta.id}.bed.gz"), emit: bed
    tuple val(meta), path("segmentation/${meta.id}.txt")   , emit: seg_txt
    tuple val(meta), path("states_${meta.id}")             , emit: states_dir
    tuple val(meta), path("counts_${meta.id}")             , emit: counts_dir
    path "versions.yml"                                    , emit: versions

    script:
    """
    set -euo pipefail

    mkdir -p counts_${meta.id} states_${meta.id} segmentation

    # 1. RUN VITERBI DECODING
    TopologyHMM \\
        -m "${model}" \\
        -v "states_${meta.id}/states.txt" \\
        -x ${counts} \\
        -r ${regions} \\
        -p ${task.cpus}

    # 2. CONVERT TO BED
    segmentation_to_bed.py \\
        -d "${config}" \\
        -i "states_${meta.id}/states.txt" \\
        -o "segmentation/" \\
        -c viterbi

    # 3. ORGANIZE OUTPUTS
    mv segmentation/*.bed.gz segmentation/${meta.id}.bed.gz
    mv segmentation/*.txt    segmentation/${meta.id}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | awk '{print \$2}')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p segmentation states_${meta.id} counts_${meta.id}
    touch segmentation/${meta.id}.bed.gz
    touch segmentation/${meta.id}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | awk '{print \$2}')
    END_VERSIONS
    """
}