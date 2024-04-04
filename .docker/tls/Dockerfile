ARG ALPINE_VERSION=1.13-alpine

FROM golang:$ALPINE_VERSION AS build

RUN apk add --no-cache sudo openssl git

# Install minica
WORKDIR /minica
RUN go get github.com/jsha/minica

COPY certs.sh /usr/local/bin/docker-certs
RUN chmod +x /usr/local/bin/docker-certs

## Create container user
ARG UID=1001
ENV UID $UID
ARG GID=1001
ENV GID $GID

ENV USER tls

RUN addgroup --system --gid $GID $USER
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
RUN chmod 0440 /etc/sudoers.d/$USER
RUN adduser --system --uid $UID --ingroup $USER $USER

## ClEAN
RUN rm -rf /tmp/* /var/cache/apk/* /var/tmp/*

USER $USER

WORKDIR /certs

ENTRYPOINT ["docker-certs"]
