#!/usr/bin/env bash

# ==============================================================================
# Initialize Variables
# ==============================================================================
MARK=()
DISTRIBUTION_HISTONE=()
STATE=""
HISTONE=""
distribution_dna=""
WGBS=""
chr=""
output_file="config.yaml"

# ==============================================================================
# Parse Command-Line Arguments
# ==============================================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--distribution_histone)
            read -r -a DISTRIBUTION_HISTONE <<< "$2"
            shift 2
            ;;
        -s|--state)
            STATE="$2"
            shift 2
            ;;
        -m|--mark)
            read -r -a MARK <<< "$2"
            shift 2
            ;;
        -h|--histone)
            HISTONE="$2"
            shift 2
            ;;
        -n|--distribution_dna)
            distribution_dna="$2"
            shift 2
            ;;
        -g|--wgbs)
            WGBS="$2"
            shift 2
            ;;
        -c|--chr)
            chr="$2"
            shift 2
            ;;
        -o|--output)
            output_file="$2"
            shift 2
            ;;  
        *) 
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;  
    esac
done 

declare -A seen_marks
unique_marks=()
unique_dists=()

for i in "${!MARK[@]}"; do
    current_mark="${MARK[$i]}"
    
    if [[ -z "${seen_marks[$current_mark]}" ]]; then
        seen_marks[$current_mark]=1
        unique_marks+=("$current_mark")
        unique_dists+=("${DISTRIBUTION_HISTONE[$i]}")
    fi
done

MARK=("${unique_marks[@]}")
DISTRIBUTION_HISTONE=("${unique_dists[@]}")

# ==============================================================================
# Output Configuration
# ==============================================================================

if [[ "${HISTONE}" == "null" ]]; then
    {
    echo "data: ${WGBS}"
    echo "distribution: ${distribution_dna}"
    echo "states: ${STATE}"
    echo "chr: [${chr}]"
    } > "${output_file}"
else
    {
    echo "states: ${STATE}"
    echo "marker: ${#MARK[@]}"
    echo "marker_spec:"

    for i in "${!MARK[@]}"; do
        echo "  - distribution: ${DISTRIBUTION_HISTONE[$i]}" 
        echo "    name: ${MARK[$i]}"
    done

    echo "data: [${HISTONE}]"

    if [[ "${WGBS}" != "null" ]]; then
        echo "dna_methylation: ${distribution_dna}"
        echo "meth_data: [${WGBS}]"
    fi

    echo "chr: [${chr}]"
    } > "${output_file}"
fi
