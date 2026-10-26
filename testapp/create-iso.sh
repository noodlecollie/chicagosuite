#! /usr/bin/bash

set -ex

genisoimage -o testapps.iso -J -input-charset utf-8 tst_cpp.exe tst_c.exe
