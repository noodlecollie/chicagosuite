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
		# Compile arguments are for release.
		"$LLVM_MINGW_XP/bin/$compiler" \
			-target i686-pc-windows-gnu \
			-fno-exceptions \
			-flto \
			-march=pentium-mmx \
			"-isystem${LLVM_MINGW_XP}/i686-w64-mingw32/include" \
			-c "$1"
	)
}

compile winnt_40.cpp
compile winnt_50.cpp
compile winnt_51.cpp
compile static_init.c
