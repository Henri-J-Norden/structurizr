# Structurizr Lite

## Building

[Official instructions](https://docs.structurizr.com/lite/building)

### Using docker
```bash
export MSYS_NO_PATHCONV=1  # If using MinGW on Windows

cd structurizr-lite
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
#DATA_DIR="/path/to/dataDirectory"
docker build . -t $TAG
docker run -it --rm -p 8080:8080 -v $DATA_DIR:/usr/local/structurizr $TAG
```
