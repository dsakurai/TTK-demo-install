#!/bin/bash

set -e

#TODO pass through input args
patch_dir="$1"

root_dir="$2"

ParaView_VERSION_NUMBER="$(./utils/latest_paraview_version_for_ttk.py "$patch_dir")"

# download the version
# git fetch origin "${version_tag}:${version_tag}"
# checkout the version
ParaView_git_dir="${root_dir}/ParaView-prefix/src/ParaView"

pushd "${ParaView_git_dir}"

echo git checkout...
git checkout "v${ParaView_VERSION_NUMBER}" || \
    echo git checkout failed. \ngit reset --hard HEAD \necho git clean -fd
echo git checkout end...

# update the submodules
git submodule update --init --recursive .
popd

# Patch ParaView
pushd "${patch_dir}"
"./patch-paraview-${ParaView_VERSION_NUMBER}.sh" "${ParaView_git_dir}"

popd

