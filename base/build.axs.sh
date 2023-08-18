#!/bin/bash

_DOCKER_OS=${DOCKER_OS:-deb}

_BASE_IMAGE=${BASE_IMAGE:-krai/axs.base:${_DOCKER_OS}_latest}
_IMAGE_NAME=${IMAGE_NAME:-krai/axs.common:${_DOCKER_OS}_latest}

# Create a non-root user with a fixed group id and a fixed user id.
QAIC_GROUP_ID=$(getent group qaic | cut -d: -f3)
_GROUP_ID=${GROUP_ID:-${QAIC_GROUP_ID}}
_USER_ID=${USER_ID:-2000}

_NO_CACHE=${NO_CACHE:-no}
if [[ "${_NO_CACHE}" == "yes" ]]; then
  __NO_CACHE="--no-cache"
fi

time docker build ${__NO_CACHE} \
--build-arg BASE_IMAGE=${_BASE_IMAGE} \
--build-arg GROUP_ID=${_GROUP_ID} \
--build-arg USER_ID=${_USER_ID} \
-f Dockerfile.axs \
-t ${_IMAGE_NAME} . 