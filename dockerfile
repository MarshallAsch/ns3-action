FROM ubuntu:focal

ARG NS3_VERSION=3.32
ARG DEBIAN_FRONTEND=noninteractive
ENV NS3_VERSION=$NS3_VERSION

WORKDIR /ns3

VOLUME ["/contrib"]


RUN apt-get update && apt-get install -y \
    g++ \
    python3 \
    python3-dev \
    pkg-config \
    sqlite \
    sqlite3 \
    libsqlite3-dev \
    python3-setuptools \
    git \
    autoconf \
    cvs \
    bzr \
    unrar \
    libxml2 \
    libxml2-dev \
    make \
    cmake \
    build-essential \
    unzip \
    mercurial \
    wget \
    qt5-default \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    python3-gi \
    python3-pygraphviz \
    python-dev \
    gsl-bin \
    libgsl0-dev



RUN wget http://www.nsnam.org/release/ns-allinone-${NS3_VERSION}.tar.bz2 && \
    tar xjf ns-allinone-${NS3_VERSION}.tar.bz2

COPY entrypoint.sh /entrypoint.sh

WORKDIR ns-allinone-${NS3_VERSION}/ns-${NS3_VERSION}


RUN ./waf configure --enable-examples --enable-tests && ./waf build



ENTRYPOINT ["/entrypoint.sh"]
