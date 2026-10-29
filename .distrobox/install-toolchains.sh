#! /usr/bin/bash

set -e

install_toolchain()
{
	URL=${1:?No URL provided}

	# Get the file name from the URL
	FILE_NAME=$(echo "$URL" | sed -E 's|https://github.com/[^/]+/[^/]+/releases/download/[^/]+/([^/]+)|\1|g')
	FILE_NAME=${FILE_NAME:?Could not parse file name from URL}

	# Get the file stem, ie. the name of the directory the file will create once extracted
	FILE_STEM=$(echo "$FILE_NAME" | sed -E 's/(.+)\.tar\.xz/\1/g')
	FILE_STEM=${FILE_STEM:?Could not compute file stem from file name}

	# Get the toolchain name from the file stem
	TOOLCHAIN_NAME=$(echo "$FILE_STEM" | sed -E 's/([^0-9]+)-[^-]+-msvcrt-ubuntu-22.04-x86_64/\1/g')
	TOOLCHAIN_NAME=${TOOLCHAIN_NAME:?Could not compute toolchain name from file stem}

	TOOLCHAIN_ENV_VAR=$(echo "$TOOLCHAIN_NAME" | tr '[:lower:]' '[:upper:]' | sed -E 's/-/_/g')

	set -x

	cd "$HOME"

	if [[ -d "./${FILE_STEM}" ]]; then
		echo "Not installing ${TOOLCHAIN_NAME} as a directory for it already exists"
		return
	fi

	wget "$URL"
	tar -xf "./${FILE_NAME}" && rm "./${FILE_NAME}"

	BASHRC_PATTERN="^export ${TOOLCHAIN_ENV_VAR}=.\+\$"
	BASHRC_REPLACEMENT="export ${TOOLCHAIN_ENV_VAR}=\"\$HOME/${FILE_STEM}\""

	if grep -q "${BASHRC_PATTERN}" "${HOME}/.bashrc"; then
		sed -i "s#${BASHRC_PATTERN}#${BASHRC_REPLACEMENT}#g" "${HOME}/.bashrc"
	else
		echo "${BASHRC_REPLACEMENT}" >> "${HOME}/.bashrc"
	fi
}

install_toolchain "https://github.com/mstorsjo/llvm-mingw/releases/download/20261020/llvm-mingw-20261020-msvcrt-ubuntu-22.04-x86_64.tar.xz"
install_toolchain "https://github.com/mon/llvm-mingw-xp/releases/download/llvm-mingw-xp-22.1.7/llvm-mingw-xp-22.1.7-msvcrt-ubuntu-22.04-x86_64.tar.xz"
