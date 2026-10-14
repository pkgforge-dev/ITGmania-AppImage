#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake \
	glew \
	glu \
	jsoncpp \
	libxinerama libxrandr \
	libmad \
	libjpeg-turbo \
	libusb-compat \
	nasm \
	pcre

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

#if [ "${DEVEL_RELEASE-}" = 1 ]; then
#	package=itgmania-git
#else
#	package=itgmania
#fi
#make-aur-package "$package"
#pacman -Q "$package" | awk '{print $2; exit}' > ~/version
echo "Building ITGmania..."
echo "---------------------------------------------------------------"
REPO="https://github.com/itgmania/itgmania"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of ITGmania..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --branch beta --single-branch --recursive --depth 1 "$REPO" ./itgmania
else
	echo "Making stable build of ITGmania..."
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//; s/^v//')"
	git clone --branch v"$VERSION" --single-branch --recursive --depth 1 "$REPO" ./itgmania
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cmake -S ./itgmania -B build \
    -DCMAKE_INSTALL_PREFIX=/opt \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_FULL_RELEASE=YES \
    -DWITH_FFMPEG_JOBS=$(nproc)
cmake --build build -j$(nproc)
cmake --install build

find /opt/itgmania -mindepth 1 -maxdepth 1 -type d ! -name "itgmania" ! -name "itgmania.desktop" -exec mv {} ./AppDir/bin \;
