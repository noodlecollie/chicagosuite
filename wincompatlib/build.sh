#! /usr/bin/bash

set -e

compile()
{
	if (echo "$1" | grep -q '.\+\.cpp$'); then
		compiler="clang++"
	else
		compiler="clang"
	fi

	(
		set -x

		# No versions specified here, they are in targetver.h instead.
		# Compile arguments are for release. They are a combination of
		# those specified in https://github.com/enlyze/EnlyzeWinCompatLib/blob/clang-vs2022/src/EnlyzeWinCompatLib.vcxproj
		# and https://github.com/Alex313031/libnt5/blob/msvc-v141-xp/BUILD.gn
		"$LLVM_MINGW_XP/bin/$compiler" \
			-target i686-pc-windows-gnu \
			-fno-exceptions \
			-flto \
			-march=pentium-mmx \
			"-isystem${LLVM_MINGW_XP}/i686-w64-mingw32/include" \
			-c "$1"
	)
}

assemble()
{
	(
		set -x

		"$LLVM_MINGW_XP/bin/clang" \
			-target i686-pc-windows-gnu \
			-march=pentium-mmx \
			-c "$1"
	)
}

link()
{
	(
		set -x

		"$LLVM_MINGW_XP/bin/llvm-ar" rcs wincompatlib.a $*
	)
}

compile winnt_40.cpp
compile winnt_50.cpp
compile winnt_51.cpp
compile static_init.c
assemble winnt_40_forwarders.asm
assemble winnt_50_forwarders.asm
assemble winnt_51_forwarders.asm

link winnt_40.o winnt_50.o winnt_51.o winnt_40_forwarders.o winnt_50_forwarders.o winnt_51_forwarders.o
