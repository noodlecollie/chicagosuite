#! /usr/bin/bash

set -ex

RELEASE_VERSION="20261020"
FILE_NAME="llvm-mingw-${RELEASE_VERSION}-msvcrt-ubuntu-22.04-x86_64.tar.xz"

cd "$HOME"
wget "https://github.com/mstorsjo/llvm-mingw/releases/download/${RELEASE_VERSION}/${FILE_NAME}"
tar -xf "./${FILE_NAME}" -C "${HOME}/llvm-mingw" && rm "./${FILE_NAME}"
cat "${HOME}/.bashrc" | grep -q "export LLVM_MINGW=" || echo "export LLVM_MINGW=\"\$HOME/llvm-mingw\"" >> "${HOME}/.bashrc"
