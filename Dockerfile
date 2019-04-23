FROM openjdk:8-jdk-alpine
MAINTAINER Dave Chevell

ENV RUN_USER            daemon
ENV RUN_GROUP           daemon

# https://confluence.atlassian.com/fisheye/fisheye-folder-layout-298976940.html
ENV FISHEYE_INST        /var/atlassian/application-data/fecru
ENV FISHEYE_HOME        /opt/atlassian/fecru

VOLUME ["${FISHEYE_INST}"]

# Expose HTTP port
EXPOSE 8060

WORKDIR $FISHEYE_INST

CMD ["/entrypoint.sh", "run"]
ENTRYPOINT ["/sbin/tini", "--"]

RUN apk add --no-cache wget curl git subversion mercurial openssh bash procps openssl perl ttf-dejavu tini
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk \
	&& apk add glibc-2.28-r0.apk \
	&& wget -P /usr/bin http://www.perforce.com/downloads/perforce/r18.2/bin.linux26x86_64/p4 \
	&& chmod +x /usr/bin/p4

COPY entrypoint.sh              /entrypoint.sh

ARG FECRU_VERSION=4.4.2
ARG DOWNLOAD_URL=https://product-downloads.atlassian.com/software/fisheye/downloads/fisheye-${FECRU_VERSION}.zip
COPY . /tmp

RUN mkdir -p                             /opt/atlassian \
    && wget -nv                          $DOWNLOAD_URL \
    && unzip -q                          fisheye-${FECRU_VERSION}.zip \
    && rm                                fisheye-${FECRU_VERSION}.zip \
    && mv                                fecru-${FECRU_VERSION} ${FISHEYE_HOME} \
    && chown -R ${RUN_USER}:${RUN_GROUP} ${FISHEYE_HOME}/
