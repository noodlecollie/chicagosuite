#! /usr/bin/bash

set -ex

"$LLVM_MINGW_XP/bin/clang++" \
	-target i686-pc-windows-gnu \
	"--sysroot=${LLVM_MINGW_XP}" \
	-fno-exceptions \
	-march=pentium-mmx \
	-municode \
	-I../02_wincompatlib \
	-c test.cpp \
	-static

# -fuse-ld=lld is required because the default linker is incorrect
# for llvm-mingw
"$LLVM_MINGW_XP/bin/clang++" -v \
	"--sysroot=${LLVM_MINGW_XP}" \
	-target i686-pc-windows-gnu \
	-fno-exceptions \
	-march=pentium-mmx \
	-municode \
	-Wl,--subsystem,windows:5.1 \
	-flto \
	-fuse-ld=lld \
	-march=pentium-mmx \
	-L../02_wincompatlib \
	-lwincompatlib \
	-lcomctl32 \
	-static \
	test.o \
	-o wincompatlib_test.exe

genisoimage -o wincompatlib_test.iso -J -input-charset utf-8 wincompatlib_test.exe
