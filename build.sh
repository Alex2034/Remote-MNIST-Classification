#!/usr/bin/env bash

set -e

while getopts 'j:b:h' flag; do
	case "${flag}" in
		j) j="${OPTARG}" ;;
		b) b="${OPTARG}" ;;
		h) echo "Usage: ./build.sh [-b <build_dir>] [-j <number-of-cores>]";
			echo -e "\t-b <path-to-build>";
			echo -e "\t\tallows to specify the build dir;";
			echo -e "\t\tdefaults to \`build\`";
			echo -e "\t-j <number-of-cores>"
			echo -e "\t\tparallel build on <number-of-cores> cores;";
			echo -e "\t\tdefaults to N=1"
			exit 0 ;;
	esac
done

job_number="${j:-1}"
build_dir="${b:-build}"

bash configure.sh -b "${build_dir}"  # -j $job_number 

cmake --build "${build_dir}" -j $job_number \
	-- -j $job_number -v -d -p
