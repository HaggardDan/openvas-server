FROM debian:buster as openvas-builder

RUN apt-get update && apt-get install -y \
    gcc \
    cmake \
    pkg-config \
    libglib2.0-dev \
    libgpgme-dev \
    libgnutls28-dev \
    uuid-dev \
    libssh-gcrypt-dev \
    libhiredis-dev \
    libxml2-dev \
    libpcap-dev \
    libldap2-dev \
    libradcli-dev \
    libnet1-dev

ADD https://github.com/greenbone/gvm-libs/archive/v21.4.0.tar.gz gvm-libs-21.4.0.tar.gz
RUN tar xzf gvm-libs-21.4.0.tar.gz && \
    cd gvm-libs-21.4.0 && \
    cmake . && \
    make install

RUN apt-get update && apt-get install -y \
    gcc \
    pkg-config \
    libssh-gcrypt-dev \
    libgnutls28-dev \
    libglib2.0-dev \
    libpcap-dev \
    libgpgme-dev \
    bison \
    libksba-dev \
    libsnmp-dev \
    libgcrypt20-dev \
    redis-server \
    rsync

ADD https://github.com/greenbone/openvas/archive/v21.4.0.tar.gz openvas-21.4.0.tar.gz
RUN tar xzf openvas-21.4.0.tar.gz && \
    cd openvas-scanner-21.4.0 && \
    cmake . && \
    make install && \
    ldconfig

#Fix the sync script so root can run it
RUN sed -i "/^#\?if.*id \-u.*/,/^#\?fi$/ s/^#*/#/" /usr/local/bin/greenbone-nvt-sync

FROM debian:buster as ospd-builder

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    libssl-dev \
    rustc
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ADD https://github.com/greenbone/ospd-openvas/archive/refs/tags/v21.4.0.tar.gz ospd-openvas-21.4.0.tar.gz
RUN pip install ospd-openvas-21.4.0.tar.gz

FROM debian:buster

ENV REDIS_URL="redis:6379"

RUN apt-get update && apt-get install -y \
    libssh-gcrypt-4 \
    libgnutls30 \
    libglib2.0-0 \
    libpcap0.8 \
    libgpgme11 \
    bison \
    libksba8 \
    libsnmp30 \
    libgcrypt20 \
    redis-server \
    rsync \
    uuid \
    libldap-2.4-2 \
    libhiredis0.14 \
    libxml2 \
    libradcli4 \
    python3 \
    python3-venv \
    gettext-base \
 && rm -rf /var/lib/apt/lists/*

ADD start.sh .

COPY --from=openvas-builder /usr/local /usr/local/.
RUN ldconfig

COPY --from=ospd-builder /opt/venv /opt/venv/.
ENV PATH="/opt/venv/bin:$PATH"

# This updates the plugins to community... but takes forever
#RUN /usr/local/bin/greenbone-nvt-sync



