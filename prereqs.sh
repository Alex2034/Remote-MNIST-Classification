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
libtorch_url="https://download.pytorch.org/libtorch/nightly/cpu/libtorch-shared-with-deps-latest.zip"

wget  -O "${lib_dir}/torch.zip" "${libtorch_url}"
unzip "${lib_dir}/libtorch-shared-with-deps-latest.zip" -d "${lib_dir}"
rm "${lib_dir}/torch.zip"

### OpenCV
wget -O "${lib_dir}/opencv.zip" https://github.com/opencv/opencv/archive/4.x.zip
unzip "${lib_dir}/opencv.zip" -d "${lib_dir}"
rm "${lib_dir}/opencv.zip"
