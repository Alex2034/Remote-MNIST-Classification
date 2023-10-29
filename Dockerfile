# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set the working directory in the container
WORKDIR /usr/src/app

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and tools
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get install -y \
    python3.9 \
    python3.9-distutils \
    python3.9-venv \
    python3-pip \
    cmake \
    g++-11 \
    git \
    wget \
    unzip \
    libopencv-dev
# Set alternatives for python and g++
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 1
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 1

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Install any additional dependencies
RUN ./prereqs.sh

# Configure the project
RUN ./configure.sh

# Compile the project
RUN ./build.sh

# Set the environment variable so that our program knows where to find the libraries
# ENV LD_LIBRARY_PATH=${TORCH_INSTALL_PREFIX}/lib:${LD_LIBRARY_PATH}

# Make port 80 available to the world outside this container
EXPOSE 80

# Run app when the container launches
CMD ["./digit-classification-model"]