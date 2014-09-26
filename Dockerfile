# Google mirrors are very fast..
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
          wget \
            --yes \
            --no-install-recommends \
            --no-install-suggests

# Clean up packages.
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the Google Cloud SDK CLI tools..
RUN wget \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip \
      --no-check-certificate && \
    unzip google-cloud-sdk.zip && \
    rm google-cloud-sdk.zip

RUN google-cloud-sdk/install.sh \
      --usage-reporting=true \
      --path-update=true \
      --bash-completion=true \
      --rc-path=/.bashrc \
      --disable-installation-options

# Install the AWS CLI.
RUN pip install \
      awscli \
      ansible

# A working volume.
VOLUME /data

# Default command.
CMD ["bash"]
