#!/bin/bash

set -e

#TODO pass through input args
root_dir="${PWD}"

patch_dir="$1"

ParaView_VERSION_NUMBER="$(./utils/latest_paraview_version_for_ttk.py "$patch_dir")"

# download the version
# git fetch origin "${version_tag}:${version_tag}"
# checkout the version
pushd ParaView 
git reset --hard HEAD
git clean -fd
echo git checkout...
git checkout "v${ParaView_VERSION_NUMBER}"
echo git checkout end...

# update the submodules
git submodule update -f --init --recursive .
popd

# Patch ParaView
pushd "${patch_dir}"
"./patch-paraview-${ParaView_VERSION_NUMBER}.sh" "${root_dir}/ParaView"

popd

