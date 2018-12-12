FROM ubuntu
USER root

# Install Python
RUN \
  apt-get update && \
  apt-get install -y wget && \
  apt-get install -y python3 python3-dev python3-pip python3-virtualenv && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/preprocessor/

# Install FSL
ENV TZ=Asia/Singapore
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN wget -O- http://neuro.debian.net/lists/jessie.us-nh.full | tee /etc/apt/sources.list.d/neurodebian.sources.list
RUN apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
RUN apt-get update
RUN wget -O /tmp/libpng.deb http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb && dpkg -i /tmp/libpng.deb
RUN apt-get install -y fsl-5.0-core fsl-first-data

# Mod FSL (for linux)
ENV FSLDIR=/usr/share/fsl/5.0

RUN whoami
RUN chown -R root:root ${FSLDIR}/etc/fslconf/fsl.sh
RUN chmod -R 700 ${FSLDIR}/etc/fslconf/fsl.sh

RUN ${FSLDIR}/etc/fslconf/fsl.sh
ENV PATH=${FSLDIR}/bin:${PATH}
ENV LD_LIBRARY_PATH=${FSLDIR}/bin:$LD_LIBRARY_PATH
RUN source ${FSLDIR}/etc/fslconf/fsl.sh

RUN wget -O ${FSLDIR}/bin/aff2rigid  https://gist.githubusercontent.com/abhinit/50e931d6281d74dc4e4fbe462d64c240/raw/a5bee0f73fa81d61cc8edec81559a8a134d9befb/aff2rigid

# Get neuropot package
RUN alias python=python3
RUN alias pip=pip3
RUN pip3 install --no-cache-dir neuropot

