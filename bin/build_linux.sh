#!/usr/bin/env bash

set -euo pipefail

# This script builds the HMM executable on Linux and places the binary
# in the pre-built directory for use with Nextflow.

# Find the absolute path to the HMM directory
HMM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/HMM"

echo "--- Cleaning up previous build ---"
rm -rf "${HMM_DIR}/build"
echo "Done."

echo "--- Configuring project with CMake ---"
mkdir "${HMM_DIR}/build"
cd "${HMM_DIR}/build"
cmake ..
echo "Done."

echo "--- Compiling with make ---"
make -j "$(nproc)"
echo "Done."

echo "--- Copying build artifacts to pre-built directory ---"
mkdir -p "${HMM_DIR}/pre-built/linux"
# Copy entire build directory contents so all artifacts (binaries, libs, cmake logs) are available
cp -a . "${HMM_DIR}/pre-built/linux/"
# Optionally remove the build directory to keep repository tidy
cd "${HMM_DIR}"
rm -rf build
echo "Successfully copied build artifacts to ${HMM_DIR}/pre-built/linux and removed build/"
