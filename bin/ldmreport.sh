#!/usr/bin/env bash

# Exit immediately if a command fails, an undefined variable is used, or a pipeline fails
set -euo pipefail

# ==========================================
# Variable Initialization
# ==========================================
YAML=""
JSON=""
SEG_DIR=""
OUTPUT=""
THREADS=""

# ==========================================
# Functions
# ==========================================
show_help(){
    cat <<HELP
Usage: $(basename "$0") [OPTIONS]

Options for making plots and HTML report:
    -y, --yaml      YAML configuration file
    -j, --json      JSON file for model
    -s, --seg-dir   Directory containing segmentation BED and TAB files
    -o, --output    Base name for output files and directory
    -@, --threads   Number of threads to use
    -h, --help      Show this help message and exit
HELP
}

# ==========================================
# Argument Parsing
# ==========================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yaml)
            YAML="$2"
            shift 2
            ;;
        -j|--json)
            JSON="$2"
            shift 2
            ;;
        -s|--seg-dir)
            SEG_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -@|--threads)
            THREADS="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'" >&2
            show_help
            exit 1
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z "${YAML}" || -z "${OUTPUT}" || -z "${JSON}" || -z "${SEG_DIR}" ]]; then
    echo "Error: Missing required arguments (--yaml, --json, --seg-dir, and --output are required)." >&2
    show_help
    exit 1
fi

# ==========================================
# Main Execution
# ==========================================
OUT_DIR="Plots"
mkdir -p "${OUT_DIR}"

# 1. Run the overall statistics (relies on YAML, runs once for the whole model)
plot_statistics.py \
    -d "${YAML}" \
    -p "${OUT_DIR}/${OUTPUT}-histogram.png" \
    -c "${OUT_DIR}/${OUTPUT}-correlation.png" \
    -m "${OUT_DIR}/${OUTPUT}-methylation-density.png"

# 2. Loop over every viterbi bed file to extract sample names and plot
for BED in "${SEG_DIR}"/viterbi_*.bed.gz; do
    
    # Extract the filename without the directory path
    filename=$(basename "$BED")
    
    # Strip the 'viterbi_' prefix and the '.bed.gz' suffix to get the pure sample ID
    # Example: viterbi_heart_E11.5_1.bed.gz -> heart_E11.5_1
    sample_id=${filename#viterbi_}
    sample_id=${sample_id%.bed.gz}

    # Define the corresponding TAB file path using the extracted sample_id
    TAB="${SEG_DIR}/${sample_id}.tab"
    
    # Set a unique prefix for this sample's plots
    PREFIX="${OUT_DIR}/${OUTPUT}_${sample_id}"

    # Run the plotting scripts dynamically for each sample
    results.py \
        -c "${TAB}" \
        -j "${JSON}" \
        -e "${PREFIX}-meanEmission.png" \
        -t "${PREFIX}-transitionMatrix.png" \
        -m "${PREFIX}-stateMembership.png" \
        -l "${PREFIX}-stateLength.png" \
        -s viterbi \
        -n "${PREFIX}-normEmission.png" \
        -d "${BED}"

    plot_state_histograms.py \
        -c "${TAB}" \
        -j "${JSON}" \
        -a "${PREFIX}-stateDistribution.png" \
        -l "${PREFIX}-statelengthDistribution.png" \
        -s viterbi

    plot_state_colors.py \
        -d "${BED}" \
        -o "${PREFIX}-state-colors.png"
done

# 3. Generate the final HTML report 
segmentation_report_dm.sh \
        -n "${OUTPUT}" \
        -o "${OUT_DIR}/" \
        -i true

echo "Plots generated successfully in ${OUT_DIR}/"