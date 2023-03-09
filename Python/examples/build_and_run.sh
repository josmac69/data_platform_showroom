#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Please provide a directory name as an argument."
    exit 1
fi

# Switch to the directory specified as a command line argument
cd $1 || { echo "Directory not found."; exit 1; }

[ ! -f "Dockerfile" ] && echo "Error: dockefile is missing." && cd - && exit 1
[ ! -f "script.py" ] && echo "Error: script.py is missing." && cd - && exit 1
[ ! -f "requirements.txt" ] && echo "Error: requirements.tx file is missing." && cd - && exit 1

# Build the Docker image with the same name as the directory
docker build --no-cache -t "python_$1" .
if [[ $? -gt 0 ]]; then
  echo "Error when building docker image"
  exit 1
fi

echo "Image $1 built successfully. Starting..."

docker run -it "python_$1":latest
if [[ $? -gt 0 ]]; then
  echo "Error when starting docker image"
  exit 1
fi

cd -

echo "All Done"
