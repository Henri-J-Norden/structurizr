# Structurizr Lite

## Building

[Official instructions](https://docs.structurizr.com/lite/building)

### Using docker
```sh
export MSYS_NO_PATHCONV=1  # If using MinGW on Windows

pushd structurizr-lite
sh ui.sh
#./gradlew clean build

# Build WAR without gradle
pushd ..
docker buildx build --target artifact --output type=local,dest=dist .
mkdir -p structurizr-lite/build/libs/
mv dist/artifacts/structurizr-lite.war structurizr-lite/build/libs/structurizr-lite.war
popd

# Create Docker image
TAG="structurizr/lite:latest"
docker build . -t $TAG --load
popd
```

```sh
# Finally, run locally
TAG="structurizr/lite:latest"
DATA_DIR="./data"
docker run -it --rm -p 8080:8080 -v $DATA_DIR:/usr/local/structurizr $TAG
```
