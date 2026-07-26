#!/usr/bin/env bash

# ==============================================================================
# Initialize Variables
# ==============================================================================
MARK=()
DISTRIBUTION_HISTONE=()
METH_MARK=()
DISTRIBUTION_DNA=()
STATE=""
HISTONE=""
WGBS=""
chr=""
output_file="config.yaml"

# ==============================================================================
# Parse Command-Line Arguments
# ==============================================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--distribution_histone) IFS=' ' read -r -a DISTRIBUTION_HISTONE <<< "$2"; shift 2 ;;
        -s|--state) STATE="$2"; shift 2 ;;
        -m|--mark) IFS=' ' read -r -a MARK <<< "$2"; shift 2 ;;
        -x|--meth_mark) IFS=' ' read -r -a METH_MARK <<< "$2"; shift 2 ;;
        -n|--distribution_dna) IFS=' ' read -r -a DISTRIBUTION_DNA <<< "$2"; shift 2 ;;
        -h|--histone) HISTONE="$2"; shift 2 ;;
        -g|--wgbs) WGBS="$2"; shift 2 ;;
        -c|--chr) chr="$2"; shift 2 ;;
        -o|--output) output_file="$2"; shift 2 ;;  
        *) echo "Error: Unknown option: $1" >&2; exit 1 ;;  
    esac
done 

# ==============================================================================
# Output Configuration
# ==============================================================================
{
    echo "states: ${STATE:-8}"
    
    # 1. Histone Markers Section
    if [[ "${#MARK[@]}" -gt 0 && "${MARK[0]}" != "null" ]]; then	
	echo "marker: ${#MARK[@]}"
        echo "marker_spec:"
        for i in "${!MARK[@]}"; do
            echo "  - name: ${MARK[$i]}"
            echo "    distribution: ${DISTRIBUTION_HISTONE[$i]:-NBI}" 
        done
    fi

    # 2. Histone Data
    if [[ -n "${HISTONE}" && "${HISTONE}" != "null" ]]; then
        echo "data: [${HISTONE}]"
    fi

    # 3. DNA Methylation Section
    if [[ "${WGBS}" != "null" && -n "${WGBS}" ]]; then
        
        # Check if we have DNA marks
        if [[ "${#METH_MARK[@]}" -gt 0 ]]; then
            echo "coverage_marker: ${#METH_MARK[@]}"
            echo "coverage_marker_spec:"
            for i in "${!METH_MARK[@]}"; do
                # Get the corresponding distribution, default to null if missing
                echo "  - name: ${METH_MARK[$i]}"
                echo "    distribution: ${DISTRIBUTION_DNA[$i]:-BI}"
            done
        fi
        echo "coverage_data: [${WGBS}]"
    fi

    echo "chr: [${chr:-12}]"
} > "${output_file}"
