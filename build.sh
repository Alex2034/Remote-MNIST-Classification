#!/usr/bin/env bash

set -e

i=0
while getopts 'j:b:l:hi' flag; do
	case "${flag}" in
		j) j="${OPTARG}" ;;
		b) b="${OPTARG}" ;;
		l) l="${OPTARG}" ;;
		h) echo "Usage: ./build.sh [-b <build_dir> -l <lib_dir> -j <number-of-cores>]";
			echo -e "\t-b <path-to-build>";
			echo -e "\t\tallows to specify the build dir";
			echo -e "\t\tinside the current directory;";
			echo -e "\t\tdefaults to \`build\`";

			echo -e "\t-l <path-to-lib>";
			echo -e "\t\tallows to specify the lib dir";
			echo -e "\t\tinside the current directory;";
			echo -e "\t\tdefaults to \`lib\`";

			echo -e "\t-j <number-of-cores>"
			echo -e "\t\tparallel build on <number-of-cores> cores;";
			echo -e "\t\tdefaults to N=1"
			echo -e "\t-i";
			echo -e "\t\t download, build prerequisites & configure";
			exit 0 ;;
		i) i=1 ;;
	esac
done

job_number="${j:-1}"
build_dir="${b:-build}"
lib_dir="${l:-lib}"

if [ $i = 1 ]; then
	bash configure.sh -b "${build_dir}" -i  # -j $job_number
fi

build_dir=$(cd "${build_dir}"; pwd)
lib_dir=$(cd "${lib_dir}"; pwd)

CMAKE_PREFIX_PATH="${lib_dir}" \
	TORCH_LIBRARIES="${lib_dir}/libtorch/lib" \
	TORCH_INCLUDE_DIRS="${lib_dir}/libtorch/include" \
	OpenCV_INCLUDE_DIRS="${lib_dir}/opencv-4.x/include"\
	cmake --build "${build_dir}"
# 	-DCMAKE_CXX_FLAGS="-Wall -Wextra" \
# 	-UTORCH_LIBRARIES -UTORCH_INCLUDE_DIRS -UOpenCV_INCLUDE_DIRS \
# 	-DTORCH_LIBRARIES="${lib_dir}/libtorch/libs" \
# 	-DTORCH_INCLUDE_DIRS="${lib_dir}/libtorch/include" \
# 	-DOpenCV_INCLUDE_DIRS="${lib_dir}/opencv-4.x/include"
# cmake --DCMAKE_PREFIX_PATH="${lib_dir}" \
# 	--build "${build_dir}" \  # -j $job_number
# 	-DCMAKE_CXX_FLAGS="-Wall -Wextra -O3 -std=c++17"  # \
# 	# -- -j $job_number -v -d -p
