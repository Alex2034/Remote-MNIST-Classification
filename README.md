# Remote-MNIST-Classification
Aim: deploy an MNIST digit classification model on a remote server. 

The project requirements are:

- Python >= 3.8
- CMake 3.16+ or better (up to 3.27.7).
- A C++17 compatible compiler (preferably g++-13+)
- Git

## Build Instructions
In the following the default build directory is `build`.
By default, `make` is executed in just one job without
parallelization.

To configure:

```bash
./configure.sh [-b <build-directory>]
```

To build:

```bash
./build.sh [-b <build-directory> -j <number-of-cores-to-use>]
```

To test:

```bash
./test.sh
```

N. B.! You might need to make the scripts used above executable
with a well-placed
```bash
chmod +x configure.sh build.sh test.sh prereqs.sh
```
