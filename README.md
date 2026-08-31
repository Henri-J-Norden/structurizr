# Structurizr Lite

<details>
<summary><h2 style="display:inline;"><a href="https://docs.structurizr.com/lite/building">Official build instructions</a></h2></summary>

> These are included without modification from the official documentation and are provided for reference only.
>
> For build instructions specific to this repository, skip this section.

### Building from source
#### Build

```
git clone https://github.com/structurizr/java.git structurizr-java
git clone --recursive https://github.com/structurizr/lite.git structurizr-lite
git clone https://github.com/structurizr/ui.git structurizr-ui
cd structurizr-java
./gradlew -Pversion=dev clean build publishToMavenLocal
cd ..
cd structurizr-lite
./ui.sh
./gradlew -PstructurizrVersion=dev clean build
```

If successful, you will see a file named structurizr-lite.war in structurizr-lite/build/libs.

### Run

To run Structurizr Lite, you can then use:

```
java -jar build/libs/structurizr-lite.war /path/to/workspace
```

(replace /path/to/workspace with the path to the folder where your workspace.dsl file is)

### Docker

To build a Docker image:

```
docker build . -t mytag
```

And to start a Docker container from this image (replace /path/to/dataDirectory):

```
docker run -it --rm -p 8080:8080 -v /path/to/dataDirectory:/usr/local/structurizr mytag
```
</details>


## Build using make

```sh
make
```


## Build manually, using docker (deprecated - use `make` instead)
```sh
export MSYS_NO_PATHCONV=1  # If using MinGW on Windows

# Prepare structurizr-lite for build
pushd structurizr-lite
sh ui.sh
#./gradlew clean build

# Build the WAR artifact inside Docker
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
