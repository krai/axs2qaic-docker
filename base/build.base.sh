#/bin/bash

#
# Copyright (c) 2021-2023 Krai Ltd.
#
# SPDX-License-Identifier: BSD-3-Clause.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

_NO_CACHE=${NO_CACHE:-no}
if [[ "${_NO_CACHE}" == "yes" ]]; then
  __NO_CACHE="--no-cache"
fi

# Use Python >= 3.7.
_PYTHON_VER=${PYTHON_VER:-3.9.16}
# Use GCC >= 9.
_GCC_MAJOR_VER=${GCC_MAJOR_VER:-11}

# Use the Austin time zone by default.
_TIMEZONE=${TIMEZONE:-"US/Central"}

# Use Ubuntu (Debian) by default.
_DOCKER_OS=${DOCKER_OS:-deb}
if [[ "${_DOCKER_OS}" == "ubuntu" || "${_DOCKER_OS}" == "deb" ]]; then
  _DOCKERFILE=Dockerfile.ubuntu
  _PYTHON_VER=3.8.10
  _GCC_MAJOR_VER=9
elif [[ "${_DOCKER_OS}" == "centos" || "${_DOCKER_OS}" == "rpm" ]]; then
  _DOCKERFILE=Dockerfile.centos
else
  _DOCKERFILE=Dockerfile.${_DOCKER_OS}
fi
_DOCKER_BASE_IMAGE="krai/axs.base:${_DOCKER_OS}_latest"

echo
echo "Building image: '${_DOCKER_BASE_IMAGE}'"
read -d '' CMD <<END_OF_CMD
time docker build ${__NO_CACHE} \
--build-arg GCC_MAJOR_VER=${_GCC_MAJOR_VER} \
--build-arg PYTHON_VER=${_PYTHON_VER} \
--build-arg PYTHON_MAJOR_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f1) \
--build-arg PYTHON_MINOR_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f2) \
--build-arg PYTHON_PATCH_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f3) \
--build-arg TIMEZONE=${_TIMEZONE} \
-f Dockerfile.ubuntu \
-t ${_DOCKER_BASE_IMAGE} .
END_OF_CMD
echo "Command: '${CMD}'"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi

echo
echo "DONE (building '${_DOCKER_BASE_IMAGE}')."
echo
