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


###############################################################################
# AXS common setup
###############################################################################

# Download original model and dataset
RUN axs byquery inference_ready,openimages_annotations,v2_1
RUN axs byquery downloaded,openimages_mlperf,validation+
RUN axs byquery openimages_mlperf,calibration
RUN axs byquery preprocessed,dataset_name=openimages,preprocess_method=pillow_torch,index_file=openimages_cal_images_list.txt,calibration+
RUN axs byquery preprocessed,dataset_name=openimages,preprocess_method=pillow_torch,first_n=24781,quantized+

# Copy in QAIC SDK.
COPY --from=qaic /opt/qti-aic/ /opt/qti-aic/
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/qti-aic/dev/lib/x86_64
ENV PATH=/usr/local/bin:${PATH}

# Generate profile: batchSize=1
RUN axs byquery profile,sut_name=gen_qaic_profile,device=qaic,model_name=retinanet,index_file=openimages_cal_images_list.txt #after updating, this should work now

# Welcome Message
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
axs byquery compiled,device=qaic,kilt_executable,retinanet --- , remove && axs byquery compiled,device=qaic,kilt_executable,retinanet\n\
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
@@    @@@@    @@@@   @@@@@    @@@   @@@@@@@@    @@@@    @@@axs.retinanet\n\
\n\
Welcome to the Krai Ltd Docker container!\n\
Container Name: $(hostname)\n\
"\n\
/bin/bash' >> /home/krai/welcome.sh

# Make the script executable
RUN chmod +x /home/krai/welcome.sh

# Entry point runs
CMD [ "/home/krai/welcome.sh" ]