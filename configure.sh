#!/usr/bin/env bash

i=0
while getopts 'b:l:hi' flag; do
	case "${flag}" in
		b) b="${OPTARG}" ;;
		l) l="${OPTARG}" ;;
		h) echo "Configure the project";
			echo "Usage: ./configure.sh [-b <build_dir> -l <lib_dir> -i]";
			echo -e "\t-b <build_dir>";
			echo -e "\t\tallows to specify the build directory;";
			echo -e "\t\tdefaults to \`build\`";
			echo -e "\t-l <path-to-lib>";
			echo -e "\t\tallows to specify the lib dir";
			echo -e "\t\tinside the current directory;";
			echo -e "\t\tdefaults to \`lib\`";
			echo -e "\t-i";
			echo -e "\t\t download, build prerequisites (\`./prereqs.sh\`)";
			exit 0 ;;
		i) i=1 ;;
	esac
done

build_dir="${b:-build}"

build_dir=$(mkdir -p "${build_dir}"; cd "${build_dir}"; pwd)

lib_dir="${l:-lib}"

lib_dir=$(mkdir -p "${lib_dir}"; cd "${lib_dir}"; pwd)

if [ $i = 1 ]; then
	bash prereqs.sh -l "${lib_dir}"
fi



echo "Proceeding to configure the project in \`${build_dir}\` directory..."

cmake -DCMAKE_PREFIX_PATH="${lib_dir}" \
	-S . -B "${build_dir}" \
	-UTORCH_LIBRARIES -UTORCH_INCLUDE_DIRS -UOpenCV_INCLUDE_DIRS \
	-DTORCH_LIBRARIES="${lib_dir}/libtorch/lib" \
	-DTORCH_INCLUDE_DIRS="${lib_dir}/libtorch/include" \
	-DOpenCV_INCLUDE_DIRS="${lib_dir}/opencv-4.x/include"
#	-DCMAKE_CXX_FLAGS="-Wall -Wextra"
