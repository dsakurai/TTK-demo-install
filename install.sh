#!/bin/bash

# Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
# Email: d.sakurai@computer.org

# stop on error
set -e

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

# for developers
echo "Show the developer notes? [n]/y (Hit enter to ignore.)"
read -rsn1 yes && [[ $yes = y ]] && cat DeveloperNotes.md
echo


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

# configure and build
cmake .

# Fin.
echo
echo "Installation finished."
echo
echo "We wish to hear from our precious users like you (that's the point of the TTK project!)"
echo "Please subscribe to TTK's user mailing list"
echo "ttk-users+subscribe@googlegroups.com"

