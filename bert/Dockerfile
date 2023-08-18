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

# Download original tensorflow bert large model
RUN axs byquery python_package,package_name==gdown
RUN axs byquery onnx_conversion_ready,tf_model,model_name=bert_large

# Download dataset
RUN axs byquery tokenized,squad_v1_1,calibration=yes && axs byquery tokenized,squad_v1_1,calibration=no

# Download model/dataset/runtime dependencies and perform runs
USER krai:kraig
RUN axs byquery compiled,protobuf
RUN axs byquery efficient_seq_packed,squad_v1_1
RUN axs byquery quant_ready,onnx_model,packed,model_name=bert_large

# Copy in QAIC SDK.
COPY --from=qaic /opt/qti-aic/ /opt/qti-aic/
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/qti-aic/dev/lib/x86_64
ENV PATH=/usr/local/bin:${PATH}

# Generate profile
RUN axs byquery profile,device=qaic,model_name=bert-99,sut_name=gen_qaic_profile

# Add the commands to the script
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
axs byquery compiled,device=qaic,kilt_executable,bert --- , remove && axs byquery compiled,device=qaic,kilt_executable,bert\n\
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
@@    @@@@    @@@@   @@@@@    @@@   @@@@@@@@    @@@@    @@@axs.bert\n\
\n\
Welcome to the Krai Ltd Docker container!\n\
Container Name: $(hostname)\n\
"\n\
' >> /home/krai/welcome.sh


# Add the line count check to the welcome script
RUN echo -e '\
inputfile_path=$(axs byquery efficient_seq_packed,squad_v1_1 , get_path)/packed/inputfiles.txt\n\
line_count=$(wc -l < "$inputfile_path")\n\
if [ "$line_count" -ne 54 ]; then\n\
    echo -e "\033[31mError: inputfiles.txt should have 54 lines but has ${line_count} lines.\033[0m"\n\
    echo -e "Attempting to resolve the issue..."\n\
    axs byquery efficient_seq_packed,squad_v1_1 , remove > /dev/null 2>&1\n\
    axs byquery efficient_seq_packed,squad_v1_1 > /dev/null 2>&1\n\
    axs byquery profile,device=qaic,model_name=bert-99,sut_name=gen_qaic_profile --- , remove  > /dev/null 2>&1\n\
    echo -e "Rebuilding the profile"\n\
    axs byquery profile,device=qaic,model_name=bert-99,sut_name=gen_qaic_profile > /dev/null 2>&1\n\
    echo -e "Resolution steps applied. Please verify the results."\n\
else\n\
    echo -e "\033[32mSuccess: inputfiles.txt has passed the checker with the correct number of lines.\033[0m"\n\
fi\n\
/bin/bash' >> /home/krai/welcome.sh

# Make the script executable
RUN chmod +x /home/krai/welcome.sh

# Entry point runs
CMD [ "/home/krai/welcome.sh" ]
