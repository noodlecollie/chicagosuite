#! /usr/bin/bash

set -ex

$LLVM_MINGW_XP/bin/clang \
  -target i686-pc-windows-gnu \
  "--sysroot=${LLVM_MINGW_XP}" \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -DWIN32_LEAN_AND_MEAN \
  helloworld_console.c \
  -o helloworld_console_c.exe \
  -Wl,--subsystem,console:4.0 \
  -static

$LLVM_MINGW_XP/bin/clang \
  -target i686-pc-windows-gnu \
  "--sysroot=${LLVM_MINGW_XP}" \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -DWIN32_LEAN_AND_MEAN \
  -municode \
  helloworld_windows.c \
  -o helloworld_windows_c.exe \
  -Wl,--subsystem,windows:4.0 \
  -static

$LLVM_MINGW_XP/bin/clang++ \
  -target i686-pc-windows-gnu \
  "--sysroot=${LLVM_MINGW_XP}" \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -D__MSVCRT_VERSION__=0x0700 \
  -DWIN32_LEAN_AND_MEAN \
  -fno-exceptions \
  helloworld_console.cpp \
  -o helloworld_console_cpp.exe \
  -Wl,--subsystem,console:4.0 \
  -stdlib=libc++ \
  -static

$LLVM_MINGW_XP/bin/clang++ \
  -target i686-pc-windows-gnu \
  "--sysroot=${LLVM_MINGW_XP}" \
  -D_WIN32_WINNT=0x0501 \
  -DWINVER=0x0501 \
  -DNTDDI_VERSION=0x05010000 \
  -D__MSVCRT_VERSION__=0x0700 \
  -DWIN32_LEAN_AND_MEAN \
  -fno-exceptions \
  -municode \
  helloworld_windows.cpp \
  -o helloworld_windows_cpp.exe \
  -Wl,--subsystem,windows:4.0 \
  -stdlib=libc++ \
  -static

genisoimage \
  -o testapps_nt4.iso \
  -J \
  -R \
  -input-charset utf-8 \
  helloworld_console_c.exe \
  helloworld_console_cpp.exe \
  helloworld_windows_c.exe \
  helloworld_windows_cpp.exe
