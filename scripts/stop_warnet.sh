#!/bin/bash
#
if [ ! -d "warnet" ]; then
    echo "Error: warnet directory not found."
	exit 1
fi

cd warnet

docker_info=$(docker info)

# Setup depends on docker or docker desktop.
if grep -q "Context:.*desktop" <<< "$docker_info"; then
    echo "Stopping warnet for docker desktop."
    just stopd
else
    echo "Stopping warnet for docker."
    just stop
fi
