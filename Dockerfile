FROM ubuntu:latest

ARG REPO="https://github.com/Chia-Network/chia-blockchain.git"
ARG BRANCH="latest"

LABEL maintainer="milaq <micha.laqua@gmail.com"
LABEL chia_branch="$BRANCH"

ARG DEBIAN_FRONTEND="noninteractive"
COPY dpkg_excludes /etc/dpkg/dpkg.cfg.d/excludes

RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential curl wget jq tar unzip ca-certificates git openssl lsb-release sudo python3 python3-pip python3-dev python3.8-venv python3.8-distutils python-is-python3 python3-yaml

RUN mkdir /chia
COPY add-harvester-last-challenge-timestamp.patch /chia/add-harvester-last-challenge-timestamp.patch
RUN git clone -b $BRANCH $REPO /chia/bin && \
  cd /chia/bin && \
  git submodule update --init mozilla-ca && \
  git apply /chia/add-harvester-last-challenge-timestamp.patch && \
  chmod +x install.sh && \
  ./install.sh
RUN cd /chia/bin/

RUN useradd -m -d /chia/data -u 10000 chia

COPY chia_configure.py /chia/configure.py
COPY entrypoint.sh /entrypoint.sh

EXPOSE 8448/tcp
WORKDIR /chia
ENTRYPOINT ["bash", "/entrypoint.sh"]
