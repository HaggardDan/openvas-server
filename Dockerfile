FROM debian:buster as builder

RUN apt-get update && apt-get install -y \
    cmake \
    pkg-config \
    libglib2.0-dev \
    libgpgme-dev \
    libgnutls28-dev \
    uuid-dev \
    libssh-gcrypt-dev \
    libldap2-dev \
    libhiredis-dev \
    libxml2-dev \
    libradcli-dev \
    libpcap-dev

ADD https://github.com/greenbone/gvm-libs/archive/v20.8.0.tar.gz gvm-libs-20.8.0.tar.gz
RUN tar xzf gvm-libs-20.8.0.tar.gz && \
    cd gvm-libs-20.8.0 && \
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

ADD https://github.com/greenbone/openvas/archive/v20.8.0.tar.gz openvas-20.8.0.tar.gz
RUN tar xzf openvas-20.8.0.tar.gz && \
    cd openvas-20.8.0 && \
    cmake . && \
    make install && \
    ldconfig

#Fix the sync script so root can run it
RUN sed -i "/^#\?if.*id \-u.*/,/^#\?fi$/ s/^#*/#/" /usr/local/bin/greenbone-nvt-sync


FROM debian:buster

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
 && rm -rf /var/lib/apt/lists/*


COPY --from=builder /usr/local /usr/local/.
RUN ldconfig
RUN /usr/local/bin/greenbone-nvt-sync


