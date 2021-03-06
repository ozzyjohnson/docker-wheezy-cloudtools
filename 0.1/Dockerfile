# Google mirrors are very fast.
FROM ozzyjohnson/wheezy-python

MAINTAINER Ozzy Johnson <ozzy.johnson@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Update and install minimal.
RUN \
  apt-get update \
            --quiet && \
  apt-get install \ 
            --yes \
            --no-install-recommends \
            --no-install-suggests \
          ca-certificates \
          openssh-client \
          unzip \
          vim \
          wget && \

# Clean up packages.
  apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the Google Cloud SDK CLI tools.
RUN wget \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip \
      --ca-certificate /usr/local/share/certs/ca-root-nss.crt && \
    unzip google-cloud-sdk.zip && \
    rm google-cloud-sdk.zip && \
    google-cloud-sdk/install.sh \
      --bash-completion=true \
      --disable-installation-options \
      --path-update=true \
      --rc-path=/.bashrc \
      --usage-reporting=true

# Update pip and set up virtualenv.
RUN pip install \
      -U pip

RUN pip install \
      virtualenv

# Install the AWS CLI and ansible.
RUN pip install \
      awscli \
      ansible

# Install Python packages to support Ansible modules.
RUN pip install \
      apache-libcloud \
      boto \
      docker-py 

# Add command completion for the AWS CLI.
RUN echo "\n# Command completion for the AWS CLI.\ncomplete -C '/usr/local/bin/aws_completer' aws" >> \
      /.bashrc

# Add a working volume mount point.
ONBUILD VOLUME ["/data"]

# Add volumes for tool configuration.
ONBUILD VOLUME ["/.ansible.cfg", "/.aws", "/.boto", "/.config", "/.gce"]

# Environment for Ansible gce module.
ENV PYTHONPATH /.gce

# Default command.
CMD ["bash"]
