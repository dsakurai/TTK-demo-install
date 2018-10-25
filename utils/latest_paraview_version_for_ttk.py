#!/usr/bin/env python3
import sys

from distutils.version import StrictVersion
from os import listdir
from os.path import isfile, join
import re

mypath = "/Users/daisuke/Programs/TTK/ttk-demo-install/ttk/paraview/patch"

# https://stackoverflow.com/questions/3207219/how-do-i-list-all-files-of-a-directory
onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]

# Get the version
#p = re.compile(r'patch-paraview-([0-9.])\.sh')
p = re.compile(r'patch-paraview-([0-9.]+)\.sh')

latest_version = "0.1"
for f in onlyfiles:
    m = p.search(f)

    if m is not None:
        version = m.group(1)
        if StrictVersion(version) > StrictVersion(latest_version):
            latest_version = version

print(latest_version, end = "")

