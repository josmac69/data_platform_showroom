#!/bin/bash

version=${1:-latest}
 docker run -it -v ${PWD}:/root/workdir python:${version} /bin/bash


