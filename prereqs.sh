#!/usr/bin/env bash

set -e

while getopts 'l:h' flag; do
	case "${flag}" in
		l) l="${OPTARG}" ;;
		h) echo "Download external libraries for the project";
			echo "Usage: ./prereqs.sh [-l <lib_dir>]";
			echo -e "\t-l <lib_dir>";
			echo -e "\t\tallows to specify the lib directory";
			echo -e "\t\tinside the current path;"
			echo -e "\t\tdefaults to \`lib\`"
			exit 0 ;;
	esac
done


lib_dir="${l:-lib}"
mkdir -p "${lib_dir}"
lib_dir=$(cd "${lib_dir}"; pwd)


echo "Proceeding to download project prerequisites to \`${lib_dir}\` directory..."

### Torch
# libtorch_url="https://download.pytorch.org/libtorch/nightly/cpu/libtorch-shared-with-deps-latest.zip"
libtorch_url="https://download.pytorch.org/libtorch/cu118/libtorch-cxx11-abi-shared-with-deps-2.1.0%2Bcu118.zip"

wget  -O "${lib_dir}/torch.zip" "${libtorch_url}"
echo "Unpacking..."
unzip "${lib_dir}/torch.zip" -d "${lib_dir}"; rm "${lib_dir}/torch.zip"
echo "Done."


### OpenCV
opencv_url="https://github.com/opencv/opencv/archive/4.x.zip"
wget -O "${lib_dir}/opencv.zip" "${opencv_url}"
echo "Unpacking..."
unzip "${lib_dir}/opencv.zip" -d "${lib_dir}"; rm "${lib_dir}/opencv.zip"

cp -R "${lib_dir}/opencv-4.x/modules/core/include/opencv2/." \
	"${lib_dir}/opencv-4.x/include/opencv2/"
cp -R "${lib_dir}/opencv-4.x/modules/highgui/include/opencv2/." \
	"${lib_dir}/opencv-4.x/include/opencv2/"
echo "Done."
#
# # Create build directory
echo "Building OpenCV..."

# Configure
mkdir -p "${lib_dir}/opencv-4.x/build"
cmake -S "${lib_dir}/opencv-4.x" -B "${lib_dir}/opencv-4.x/build" \
	-DBUILD_SHARED_LIBS=OFF -DBUILD_LIST=core,highgui,imgcodecs

# Build
cmake --build "${lib_dir}/opencv-4.x/build"
cp -R "${lib_dir}/opencv-4.x/build/opencv2/." "${lib_dir}/opencv-4.x/include/opencv2/"
echo "Done."
