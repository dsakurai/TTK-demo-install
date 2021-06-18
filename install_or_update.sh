#!/bin/bash
set -e

# Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
# Email: d.sakurai@computer.org

echo CAREFUL!!!

echo "TODO This script should change the directory to the tutorial directory after a successful installation."
echo "TODO Install VTK, too?"
echo "TODO one-liner curl commnand"
echo "TODO Email to TTK-dev (not -users)"
echo "TODO What's the directory structure?"

# Record the current directory
old_dir=$PWD

# clean up on abort
# https://stackoverflow.com/questions/2129923/how-to-run-a-command-before-a-bash-script-exits
function cleanup {
    echo
    echo "error: Installing TTK failed."
#    echo "If you cannot solve the problem, ask questions via TTK's users mailing list."
    echo "${subscription_message}"
    # Back to the old directory.
    cd "${old_dir}"
}
trap cleanup ERR

# Intro
echo 
echo "Welcome!"
echo 
echo
echo "Dependencies are listed on the web page https://topology-tool-kit.github.io/installation.html"
echo "Make sure that thay are installed."
echo

# For developers
echo "Show notes for TTK contributors? y/[n] (Hit enter to ignore.)"
read -rsn1 yes && [[ $yes = y ]] && cat TTKContributorNotes.md
echo

echo "Insert a TTK version tag that you wish to install. To view available tags, visit https://github.com/topology-tool-kit/ttk". Alternatively, you can enter any git tree-ish.
echo "Hit enter to install the default version for this time."
read TTK_version_tag

# get the current directory
# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

# Change the directory to the one containing this script
cd "$DIR"

echo
echo "Enter the build type of TTK: [Release]/RelWithDebInfo/Debug"
read TTK_CMAKE_BUILD_TYPE
TTK_CMAKE_BUILD_TYPE=${TTK_CMAKE_BUILD_TYPE:-Release}
echo
echo "Enter the build type of ParaView: [Release]/RelWithDebInfo/Debug"
read ParaView_CMAKE_BUILD_TYPE
ParaView_CMAKE_BUILD_TYPE=${ParaView_CMAKE_BUILD_TYPE:-Release}
echo "Enter the install location: (Default: ${PWD}/local)"
read CMAKE_INSTALL_PREFIX
CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-${PWD}/local}

echo "Enter the build directory: (Default: build)"
read BUILD_DIR
BUILD_DIR=${BUILD_DIR:-build}

echo "Before configuring this superproject..."
echo "Do you wish to issue make commands manually right after we configure the system? y/[n]"
#
read -rsn1 manual_make

echo "Starting configuration..."

git submodule update --init --recursive .
# checkout TTK version
[[ ! -z "$TTK_version_tag" ]] && ( cd TTK && git fetch && git checkout $TTK_version_tag )

# configure the superproject
mkdir -p "${BUILD_DIR}" && cd "${BUILD_DIR}"
cmake .. \
    "-DCMAKE_BUILD_TYPE=Release" \
    "-DTTK_CMAKE_BUILD_TYPE=${TTK_CMAKE_BUILD_TYPE}" \
    "-DParaView_CMAKE_BUILD_TYPE=${ParaView_CMAKE_BUILD_TYPE}" \
    "-DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX"

# build
echo
echo "The superproject is configured."
echo
if [[ $manual_make = y ]];
    then
        echo
        echo "Run make to continue."
        echo "See available targets by issuing 'cmake --build . --target help'"

        # Leave without showing the error message
        exit 0
fi

make

