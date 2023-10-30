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
libtorch_url="https://github.com/pytorch/pytorch.git"
# libtorch_url="https://download.pytorch.org/libtorch/cpu/libtorch-static-with-deps-1.0.1.zip"
# libtorch_url="https://download.pytorch.org/libtorch/nightly/cpu/libtorch-static-with-deps-latest.zip"
# libtorch_url="https://download.pytorch.org/libtorch/cu118/libtorch-cxx11-abi-static-with-deps-2.1.0%2Bcu118.zip"

echo "Cloning..."
wd=$(pwd)
cd "${lib_dir}"
echo "Cloning Torch..."
git clone -b main --recurse-submodule "${libtorch_url}"
git submodule update --init --recursive
mkdir libtorch && cd libtorch
echo "Building Torch..."
cmake \
-DCMAKE_VERBOSE_MAKEFILE:BOOL=1 \
-DUSE_CUDA=OFF \
-DBUILD_CAFFE2=OFF \
-DBUILD_PYTHON:BOOL=OFF \
-DBUILD_CAFFE2_OPS=OFF \
-DUSE_DISTRIBUTED=OFF \
-DBUILD_TEST=OFF \
-DBUILD_BINARY=OFF \
-DBUILD_MOBILE_BENCHMARK=0 \
-DBUILD_MOBILE_TEST=0 \
-DUSE_ROCM=OFF \
-DUSE_GLOO=OFF \
-DUSE_LEVELDB=OFF \
-DUSE_MPI:BOOL=OFF \
-DBUILD_CUSTOM_PROTOBUF:BOOL=OFF \
-DUSE_NNPACK=OFF \
-DUSE_QNNPACK=OFF \
-DUSE_XNNPACK=OFF \
-DUSE_OPENMP:BOOL=OFF \
-DBUILD_SHARED_LIBS:BOOL=OFF \
-DCMAKE_BUILD_TYPE:STRING=Release \
-DPYTHON_EXECUTABLE:PATH=`which python3` \
-DUSE_MKLDNN=OFF \
-DBLAS=OpenBLAS \
-DCMAKE_INSTALL_PREFIX:PATH=../libtorch \
../pytorch
cmake --build . --target install -- "-j8"
cd "${wd}"
# wget  -O "${lib_dir}/torch.zip" "${libtorch_url}"
# echo "Unpacking..."
# unzip "${lib_dir}/torch.zip" -d "${lib_dir}"; rm "${lib_dir}/torch.zip"
echo "Done."


### OpenCV
# opencv_url="https://github.com/opencv/opencv/archive/4.x.zip"
opencv_url="https://github.com/opencv/opencv.git"
echo "Cloning OpenCV..."
git clone "${opencv_url}"
# wget -O "${lib_dir}/opencv.zip" "${opencv_url}"
# echo "Unpacking..."
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
cmake -D CMAKE_BUILD_TYPE=Release -D GLIBCXX_USE_CXX11_ABI=0 \
	-S "${lib_dir}/opencv-4.x" -B "${lib_dir}/opencv-4.x/build" \
	-DBUILD_SHARED_LIBS=OFF -DBUILD_LIST=core,highgui,imgcodecs,imgproc

# Build
cmake --build "${lib_dir}/opencv-4.x/build"
cp -R "${lib_dir}/opencv-4.x/build/opencv2/." "${lib_dir}/opencv-4.x/include/opencv2/"
echo "Done."
