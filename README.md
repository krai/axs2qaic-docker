# Setup Docker for QAIC devices

## Get Docker repository

```
mkdir -p ${WORKDIR}/${USER}
cd ${WORKDIR}/${USER}
```

## Build base images

### Base

```
DOCKER_OS=deb ./build.base.sh
```

### QAIC
```
DOCKER_OS=deb ./build.qaic.sh
```

### AXS
```
DOCKER_OS=deb ./build.axs.sh
```

### Imagenet for resnet50
```
cd ../imagenet && DATASETS_DIR=/local/mnt/workspace/datasets IMAGENET=full ./build.imagenet.sh
```

## Build benchmark images
```
cd axs2qaic-docker
```

Defaults:
- `SDK_VER=1.9.1.25`
- `...`

```
BENCHMARK=${BENCHMARK} ./build.benchmark.sh
```