#!/bin/bash -x

echo "Building Docker container"
docker build . -t "rigetticomputing/oqaml"

echo "Starting container and mounting local directory"
CONT_ID=$(docker run -v $(pwd):/root/oqaml -td rigetticomputing/oqaml /bin/bash)

echo "Executing unit tests"
docker exec -e -ti $CONT_ID make -C /root/oqaml test
SUCCESS_FLAG=$?

echo "Stopping container"
docker stop $CONT_ID

exit $SUCCESS_FLAG
