#!/bin/bash

set -euo pipefail

# Required inputs
input_file=""
regions_file="" # Replaces reference_file based on new requirements
output_file=""

# Optional inputs with defaults
binsize=200
pair_mode="ignore"
cores=4
genome=""

print_usage() {
    echo "Usage: $0 -i <metadata.txt> -r <regions_file> -o <output_file> [-b <binsize>] [-p <pair_mode>] [-c <cores>] [-g <genome>]"
    echo ""
    echo "Required:"
    echo "  -i  Input metadata file"
    echo "  -r  Regions file (chr, start, length in bp)"
    echo "  -o  Output file"
    echo ""
    echo "Optional:"
    echo "  -b  Binsize in base pairs. Default: 200"
    echo "  -p  Pair mode (ignore, filter, midpoint). Default: ignore"
    echo "        ignore   - treat like single end"
    echo "        filter   - 5'-end of first read in a properly aligned pair"
    echo "        midpoint - consider the midpoint of an aligned fragment"
    echo "  -c  Number of cores to be used. Default: 4"
    echo "  -g  Genome version (e.g., mm10, hg19, hg38)"
    exit 1
}

while getopts "i:r:o:b:p:c:g:" flag; do
    case "${flag}" in
        i) input_file="${OPTARG}" ;;
        r) regions_file="${OPTARG}" ;;
        o) output_file="${OPTARG}" ;;
        b) binsize="${OPTARG}" ;;
        p) pair_mode="${OPTARG}" ;;
        c) cores="${OPTARG}" ;;
        g) genome="${OPTARG}" ;;
        *) print_usage ;;
    esac
done

# Validate required arguments
if [[ -z "$input_file" || -z "$regions_file" || -z "$output_file" ]]; then
    echo "Error: Missing required arguments." >&2
    print_usage
fi

# Validate pair_mode option
if [[ "$pair_mode" != "ignore" && "$pair_mode" != "filter" && "$pair_mode" != "midpoint" ]]; then
    echo "Error: Invalid option for -p. Must be 'ignore', 'filter', or 'midpoint'." >&2
    exit 1
fi

# Validate file existence
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' not found." >&2
    exit 1
fi

if [[ ! -f "$regions_file" ]]; then
    echo "Error: Regions file '$regions_file' not found." >&2
    exit 1
fi

# Process input file
awk '{print>$3}' "$input_file"

# Write parameters to output file
: > "$output_file"
{
    echo "--- Execution Parameters ---"
    echo "Input file: $input_file"
    echo "Regions file: $regions_file"
    echo "Output file: $output_file"
    echo "Binsize: $binsize"
    echo "Pair mode: $pair_mode"
    echo "Cores: $cores"
    echo "Genome: ${genome:-Not specified}"
    echo "----------------------------"
    echo ""
} >> "$output_file"

echo "Output written to $output_file"
