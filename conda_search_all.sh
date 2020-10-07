#!/bin/bash
#
# Search all supported conda architectures for a given package/spec
#
# Examples
# --------
#
# To search in main/defaults:
#
# $ ./conda_search_all.sh numpy=1.19
#
# To search in conda-forge channel
#
# $ ./conda_search_all.sh conda-forge::numpy=1.19

all_archs=("linux-64" "linux-32" "osx-64" "win-64" "win-32" "linux-aarch64" "linux-armv7l" "linux-ppc64le")
for arch in ${all_archs[@]}
do
    echo "--------------------------------------------------"
    echo "Searching spec $1 for architecture: $arch"
    CONDA_SUBDIR=$arch conda search $1
done
