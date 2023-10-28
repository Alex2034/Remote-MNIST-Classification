#!/usr/bin/env bash

while getopts 'b:h' flag; do
	case "${flag}" in
		b) b="${OPTARG}" ;;
		h) echo "Configure the project";
			echo "Usage: ./configure.sh [-b <build_dir>]";
			echo -e "\t-b <build_dir>";
			echo -e "\t\tallows to specify the build directory;";
			echo -e "\t\tdefaults to \`build\`"
			exit 0;;
	esac
done

build_dir="${b:-build}"

mkdir $build_dir  # && cd build

echo "Proceeding to configure the project in $build_dir directory..."

cmake -S . -B $build_dir \
	-DCMAKE_CXX_FLAGS="-Wall -Wextra"
