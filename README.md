# OpenVAS-Server

OpenVAS is an opensource project forked off of the original Nessus opensource code.  This is a dockerbuild of the source distro.

Now with ospd-openvas build it.

## Build

    docker build . -t openvas-server:latest

## ENV Parameters

 * `REDIS_URL` (default redis:6379): target redis to use to manage KB data.

## Run

    docker run openvas-server:latest