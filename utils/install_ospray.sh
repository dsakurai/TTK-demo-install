#!/usr/bin/env bash

#  Exit on error
set -o errexit

for each in "$1/"*; do
    cp -rp "$each" "$2"
done

