#!/usr/bin/env bash

set -euo pipefail

# This script builds the HMM executable on macOS and places the binary
# in the pre-built directory for use with Nextflow.

# Find the absolute path to the HMM directory
HMM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/HMM"

echo "--- Cleaning up previous build ---"
rm -rf "${HMM_DIR}/build"
echo "Done."

echo "--- Configuring project with CMake ---"
mkdir "${HMM_DIR}/build"
cd "${HMM_DIR}/build"
export Boost_DIR=/opt/homebrew/lib/cmake/Boost-1.90.0
cmake ..
echo "Done."

echo "--- Compiling with make ---"
make -j "$(sysctl -n hw.ncpu)"
echo "Done."

echo "--- Copying build artifacts to pre-built directory ---"
mkdir -p "${HMM_DIR}/pre-built/mac"
# Copy entire build directory contents so all artifacts (binaries, libs, cmake logs) are available
cp -a . "${HMM_DIR}/pre-built/mac/"
# Optionally remove the build directory to keep repository tidy
cd "${HMM_DIR}"
rm -rf build
echo "Successfully copied build artifacts to ${HMM_DIR}/pre-built/mac and removed build/"
