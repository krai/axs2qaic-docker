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

###############################################################################
# IMPORT STAGE
#
# In this stage, "import" the 'krai/qaic' image.
#
###############################################################################
ARG DOCKER_OS
ARG SDK_VER
FROM krai/axs.qaic:${DOCKER_OS}_${SDK_VER} AS qaic

###############################################################################
# FINAL STAGE
#
# In this stage, copy in QAIC SDK, and then calibrate and compile the workload.
#
###############################################################################
FROM krai/axs.common:${DOCKER_OS}_latest

# Download model.
RUN axs byquery inference_ready,tf_model,model_name=resnet50
# Prepare "shape_fixed" model.
RUN axs byquery tf_model,shape_fixed,model_name=resnet50

# Copy the ImageNet validation dataset (50,000 images) from Docker image.
COPY --from=imagenet ./imagenet ./imagenet
# Preprocess quantized full dataset for running benchmark.
RUN axs byquery preprocessed,dataset_name=imagenet,preprocess_method=opencv,first_n=50000,quantized+,images_directory=/home/krai/imagenet

# Preprocess MLPerf calibration dataset (500 images) for generating profiles.
RUN axs byquery preprocessed,dataset_name=imagenet,preprocess_method=opencv,index_file=cal_image_list_option_1.txt,normalayout+,images_directory=/home/krai/imagenet

# Copy in QAIC SDK.
COPY --from=qaic /opt/qti-aic/ /opt/qti-aic/
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/qti-aic/dev/lib/x86_64
ENV PATH=/usr/local/bin:${PATH}

# Generate 2 profiles: batchSize=1 for SingleStream/MultiStream, batchSize=8 for Offline/Server.
RUN axs byquery profile,model_name=resnet50,device=qaic,index_file=cal_image_list_option_1.txt,sut_name=gen_qaic_profile,batchSize=1
RUN axs byquery profile,model_name=resnet50,device=qaic,index_file=cal_image_list_option_1.txt,sut_name=gen_qaic_profile,batchSize=8

RUN echo -e '#!/bin/bash\n\
for dir in ~/work_collection/*/ ; do \n\
    if [ -d "${dir}/.git" ]; then \n\
        echo -e "Updating repository in directory: ${dir}"\n\
        cd ${dir} && \n\
        git stash --quiet && \n\
        git pull --quiet && \n\
        cd ../ ; \n\
    fi; \n\
done\n\
/opt/qti-aic/tools/qaic-util -q | grep Status\n\
axs byquery compiled,lib_kilt --- , remove && axs byquery compiled,lib_kilt\n\
axs byquery compiled,device=qaic,kilt_executable,resnet50 --- , remove && axs byquery compiled,device=qaic,kilt_executable,resnet50\n\
echo -e "DONE: Compile kilt binaries"\n\
' > /home/krai/welcome.sh

RUN echo -e 'echo -e "\
@@    @@@@@   @@@@          @@@@@@@@@@@   @@@@@@@@@@    @@(Please git pull)\n\
@@    @@@@    @@@@           @@@@@@@@@     @@@@@@@@@    @@\n\
@@    @@@    @@@@@   @@@@@   @@@@@@@@@     @@@@@@@@@    @@\n\
@@    @@    @@@@@@   @@@@@@   @@@@@@@   @   @@@@@@@@    @@\n\
@@    @    @@@@@@@   @@@@@@   @@@@@@@   @   @@@@@@@@    @@\n\
@@        @@@@@@@@   @@@@@   @@@@@@@    @    @@@@@@@    @@\n\
@@      @@@@@@@@@@           @@@@@@@   @@@   @@@@@@@    @@\n\
@@       @@@@@@@@@          @@@@@@@    @@@   @@@@@@@    @@\n\
@@        @@@@@@@@         @@@@@@@@   @@@@@   @@@@@@    @@\n\
@@    @    @@@@@@@   @@@    @@@@@@@   @@@@@   @@@@@@    @@\n\
@@    @@    @@@@@@   @@@@   @@@@@@   @@@@@@@   @@@@@    @@\n\
@@    @@@    @@@@@   @@@@@    @@@    @@@@@@@   @@@@@    @@\n\
@@    @@@@    @@@@   @@@@@    @@@   @@@@@@@@    @@@@    @@@axs.resnet50\n\
\n\
Welcome to the Krai Ltd Docker container!\n\
Container Name: $(hostname)\n\
"\n\
/bin/bash' >> /home/krai/welcome.sh

RUN chmod +x /home/krai/welcome.sh

# Entry point runs
CMD [ "/home/krai/welcome.sh" ]