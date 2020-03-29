SERVER=$1

if [ -z "$SERVER" ];
then
  echo "do nothing..."
else
  docker build -t builder .

  HASH=$(git rev-parse HEAD)
  VERSION=${HASH:0:8}

  echo "login docker..."
  docker login --username "${DOCKER_USERNAME}" --password "${DOCKER_PASSWORD}" "$SERVER"

  echo "Build bot ${VERSION}..."
  docker build -t "$SERVER/builder:$VERSION" -f Dockerfile .
  docker push "$SERVER/builder:$VERSION"
fi;