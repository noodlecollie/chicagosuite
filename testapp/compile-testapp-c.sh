#! /usr/bin/bash

set -ex

$LLVM_MINGW/bin/clang \
  -target i686-pc-windows-gnu \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -DWIN32_LEAN_AND_MEAN \
  testapp.c \
  -o tst_c.exe \
  -Wl,--subsystem,console:5.1 \
  -static
