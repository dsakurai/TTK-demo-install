#!/bin/bash

# Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
# Email: d.sakurai@computer.org

echo "TODO This script should change the directory to the tutorial directory after a successful installation."
echo "TODO Install VTK, too?"
echo "TODO one-liner curl commnand"
echo "TODO Email to TTK-dev (not -users)"
echo "TODO What's the directory structure?"

# abort on error
set -e

subscription_message="Send an empty email to ttk-users+subscribe@googlegroups.com to subscribe to TTK's user mailing list."

# Record the current directory
old_dir=$PWD

# clean up on abort
# https://stackoverflow.com/questions/2129923/how-to-run-a-command-before-a-bash-script-exits
function cleanup {
    echo
    echo "error: Installing TTK failed."
    echo "If you cannot solve the problem, ask questions via TTK's users mailing list."
    echo "${subscription_message}"
    # Back to the old directory.
    cd "${old_dir}"
}
trap cleanup ERR

# Intro
echo 
echo "Welcome to TTK!"
echo " - URL: https://topology-tool-kit.github.io"
echo " - Mailing list:"
echo "     - Subscribe? Send an empty email to ttk-users+subscribe@googlegroups.com"
echo "     - Report problems to ttk-users@googlegroups.com after subscription"
echo "     - Questions are highly welcome, too"
echo 
echo
echo "Dependencies are listed on the web page https://topology-tool-kit.github.io/installation.html"
echo "Make sure that thay are installed."
echo

# For developers
echo "Show notes for TTK contributors? y/[n] (Hit enter to ignore.)"
read -rsn1 yes && [[ $yes = y ]] && cat TTKContributorNotes.md
echo

echo "Insert a TTK version tag that you wish to install. To view available tags, visit https://github.com/topology-tool-kit/ttk"
echo "Hit enter to install the latest version (technically the default git branch)."
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

echo "Use the latest ParaView that can be patched for TTK? [y]/n"
read -rsn1 yes
if [[ $yes != n ]]; then
    ParaView_USE_LATEST_PATCHABLE=ON
else
    # No => set the git tag
    echo "Insert a ParaView version tag that you wish to install."
    echo "To view available tags, visit https://github.com/Kitware/ParaView.git"
    echo "Hit enter to install the latest version (technically the default git branch)."
    echo "WARNING!!! DO NOT MODIFY the contents controlled by ParaView's git working directory. This script may remove your work. If you have to, be sure to commit your changes before you continue with this script."
    read ParaView_VERSION_TAG
fi

# configure the superproject
cmake . \
    "-DTTK_VERSION_TAG=$TTK_version_tag" \
    "-DParaView_USE_LATEST_PATCHABLE=${ParaView_USE_LATEST_PATCHABLE}" \
    "-DParaView_VERSION_TAG=$ParaView_VERSION_TAG"

# build
echo
echo "The superproject is configured."
echo
echo "Proceed to build? [y]/n"
echo "WARNING!!! A build will try to apply patches, removing all the changes you made in the git working directory of ParaView and so on."

read -rsn1 yes
if [[ $yes != n ]];
    then
        make
    else
        echo
        echo "Run make to continue the installation."
        echo "See available targets by issuing 'cmake --build . --target help'"

        # Leave without showing the error message
        #set +e
        exit 0
fi

# Fin.
echo
echo ---------------------------------------
echo "TTK developers love to hear from you."
echo "${subscription_message}"

