#!/usr/bin/env python3
import sys

from distutils.version import StrictVersion
from os import listdir
from os.path import isfile, join
import re

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("path")
parser.add_argument(
        "--first_two", 
        help="Only return the first two version digits. Eg. 5.10.2 => 5.10",
        action="store_true"
        )

args = parser.parse_args()

# patch directory
mypath = args.path
first_two = args.first_two

# https://stackoverflow.com/questions/3207219/how-do-i-list-all-files-of-a-directory
onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]

# Get the version
p = re.compile(r'patch-paraview-([0-9.]+)\.sh')

latest_version = "0.1"
for f in onlyfiles:
    m = p.search(f)

    if m is not None:
        version = m.group(1)
        if StrictVersion(version) > StrictVersion(latest_version):
            latest_version = version

if first_two:
    p_two = re.compile(r'^[0-9]+\.[0-9]+')
    m = p_two.search(latest_version)
    latest_version = m.group()

print(latest_version, end = "")

