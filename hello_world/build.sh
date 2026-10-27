#! /usr/bin/bash

set -ex

$LLVM_MINGW_XP/bin/clang \
  -target i686-pc-windows-gnu \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -DWIN32_LEAN_AND_MEAN \
  testapp.c \
  -o tst_c.exe \
  -Wl,--subsystem,console:5.1 \
  -static

$LLVM_MINGW_XP/bin/clang++ \
  -target i686-pc-windows-gnu \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -D__MSVCRT_VERSION__=0x0700 \
  -DWIN32_LEAN_AND_MEAN \
  -fno-exceptions \
  testapp.cpp \
  -o tst_cpp.exe \
  -Wl,--subsystem,console:5.1 \
  -stdlib=libc++ \
  -static

genisoimage -o testapps.iso -J -input-charset utf-8 tst_cpp.exe tst_c.exe
