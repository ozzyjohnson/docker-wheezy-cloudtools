# Google mirrors are very fast.
FROM google/debian:wheezy

MAINTAINER Ozzy Johnson <ozzy.johnson@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Update and install minimal.
RUN \
  apt-get update \
            --quiet && \
  apt-get install \ 
          build-essential \
          python \
          python-dev \
          python-pip \
          python-virtualenv \
          unzip \
          vim \
          wget \
            --yes \
            --no-install-recommends \
            --no-install-suggests

# Clean up packages.
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the Google Cloud SDK CLI tools.
RUN wget \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip \
      --no-check-certificate && \
    unzip google-cloud-sdk.zip && \
    rm google-cloud-sdk.zip

RUN google-cloud-sdk/install.sh \
      --bash-completion=true \
      --disable-installation-options \
      --path-update=true \
      --rc-path=/.bashrc \
      --usage-reporting=true

# Install the AWS CLI and ansible.
RUN pip install \
      awscli \
      ansible

# Add command completion for the AWS CLI.
RUN echo "\n# Command completion for the AWS CLI.\ncomplete -C '/usr/local/bin/aws_completer' aws" >> \
      /.bashrc

# Add a working volume mount point.
VOLUME ["/data"]

# Add volumes for tool configuration.
VOLUME ["/.ansible.cfg", "/.aws", "/.config"]

# Default command.
CMD ["bash"]
