#!/bin/bash

set -e

patch_dir="$1"

ParaView_git_dir="$2"

ParaView_VERSION_NUMBER="$(./utils/latest_paraview_version_for_ttk.py "$patch_dir")"

# checkout the version

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

