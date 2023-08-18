ARG BASE_IMAGE
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/bin/bash", "-c"]

# Create user 'krai' in group 'kraig'.
ARG GROUP_ID
ARG USER_ID
RUN groupadd -g ${GROUP_ID} kraig\
 && useradd -u ${USER_ID} -g kraig --create-home --shell /bin/bash krai
RUN echo 'krai ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER krai:kraig
RUN git config --global user.name "krai"\
 && git config --global user.email "info@krai.ai"

WORKDIR /home/krai

# Install the kernel of the AXS workflow automation framework.
RUN git clone --depth 3 https://github.com/krai/axs
ENV PATH="$PATH:/home/krai/axs"

# Detect python.
RUN axs byquery shell_tool,can_python

# Download AXS repos.
RUN echo "Avoid cache: $(date)" > /dev/null
RUN axs byquery git_repo,collection,repo_name=axs2kilt,checkout=main &&\
 axs byquery git_repo,collection,repo_name=axs2config,checkout=main &&\
 axs byquery git_repo,collection,repo_name=axs2system,checkout=main &&\
 axs byquery git_repo,collection,repo_name=axs2qaic,checkout=main &&\
 axs byquery git_repo,repo_name=kilt-mlperf,checkout=main &&\
 axs byquery git_repo,collection,repo_name=axs2mlperf

CMD [ "axs version" ]
