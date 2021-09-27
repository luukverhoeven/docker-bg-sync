FROM alpine
MAINTAINER Luuk Verhoeven (Ldesign Media)

# Install needed packages.
#RUN apt-get -qq update && \
#    apt-get -qq install inotify-tools rsync unison-all && \
#    apt-get clean && \
#    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Alpine doesn't ship with Bash.
RUN apk add --no-cache bash

# Install Unison from source with inotify support + remove compilation tools
ARG UNISON_VERSION=2.51.4
RUN apk add --no-cache --virtual .build-dependencies build-base curl
RUN apk add --no-cache inotify-tools
RUN apk add --no-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ ocaml
RUN curl -L https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz | tar zxv -C /tmp
RUN cd /tmp/unison-${UNISON_VERSION} &&  make UISTYLE=text NATIVE=true STATIC=true
#RUN sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' src/fsmonitor/linux/inotify_stubs.c

RUN cp /tmp/unison-${UNISON_VERSION}/src/unison /tmp/unison-${UNISON_VERSION}/src/unison-fsmonitor /usr/local/bin
RUN rm -rf /tmp/unison-${UNISON_VERSION}

ENV HOME="/root" \
    UNISON_USER="root" \
    UNISON_GROUP="root" \
    UNISON_UID="0" \
    UNISON_GID="0"

# Copy the bg-sync script into the container.
COPY sync.sh /usr/local/bin/bg-sync
RUN chmod +x /usr/local/bin/bg-sync

CMD ["bg-sync"]
