#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Please provide a directory name as an argument."
    exit 1
fi

# Switch to the directory specified as a command line argument
cd $1 || { echo "Directory not found."; exit 1; }

# Build the Docker image with the same name as the directory
docker build --no-cache -t "python_$1" .
echo "Image $1 built successfully. Starting..."

docker run -it "python_$1":latest

echo "All Done"
