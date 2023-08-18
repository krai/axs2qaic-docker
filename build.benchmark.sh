#!/bin/bash

_BENCHMARK=${BENCHMARK:-resnet50}
_DOCKER_OS=${DOCKER_OS:-deb}
_SDK_VER=${SDK_VER:-1.9.1.25}
_DATE=$(date +'%Y%m%d')

_IMAGE_NAME=${IMAGE_NAME:-krai/axs.${_BENCHMARK}:${_DOCKER_OS}_${_SDK_VER}_${SUT}_${_DATE}}
echo "Building ${_IMAGE_NAME} Docker image for ${SUT}."

_NO_CACHE=${NO_CACHE:-no}
if [[ "${_NO_CACHE}" == "yes" ]]; then
  __NO_CACHE="--no-cache"
fi

time docker build ${__NO_CACHE} \
--build-arg DOCKER_OS=${_DOCKER_OS} \
--build-arg SDK_VER=${_SDK_VER} \
-f $(pwd)/${_BENCHMARK}/Dockerfile \
-t ${_IMAGE_NAME} $(pwd)/${_BENCHMARK}

echo "DONE."
echo
