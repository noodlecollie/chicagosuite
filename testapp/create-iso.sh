#! /usr/bin/bash

set -ex

genisoimage -o testapps.iso -input-charset utf-8 testapp_c.exe testapp_cpp.exe
