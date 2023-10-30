#!/usr/bin/env bash

# Set the script to exit immediately on error
set -e

# Define the Python executable to use
PYTHON_EXECUTABLE="python3"

# Check if the user has specified a Python version
while getopts "p:h" opt; do
  case $opt in
    p)
      PYTHON_EXECUTABLE="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-p <python_executable>]"
      echo -e "\t-p <python_executable>: Specify the Python executable to use (default: python3)"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Run the tests
echo "Running tests with $PYTHON_EXECUTABLE..."
$PYTHON_EXECUTABLE -m coverage run -m \
  unittest discover -s tests  # -p "test_*.py"
