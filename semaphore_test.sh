#!/bin/bash

echo "Building Docker container"
docker build . -t "rigetticomputing/oqaml"

echo "Starting container and mounting local directory"
CONT_ID=$(docker run -v $(pwd):/root/oqaml -td rigetticomputing/oqaml /bin/bash)

echo "Executing unit tests"
docker exec -ti $CONT_ID make -C /root/oqaml oasis-test

echo "Stopping container"
docker stop $CONT_ID
