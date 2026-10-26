#! /usr/bin/bash

set -ex

$LLVM_MINGW/bin/clang \
  -target i686-pc-windows-gnu \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  testapp.c \
  -o testapp_c.exe \
  -Wl,--subsystem,windows:5.1 \
  -static
