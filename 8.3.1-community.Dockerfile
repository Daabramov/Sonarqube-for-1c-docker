FROM adoptopenjdk:11-jdk-hotspot as builder

WORKDIR /tmp

ARG SONAR_BRANCH_PLUGIN_BRANCH=sq-8_2-support

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git \
	&& rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf

RUN git clone https://github.com/mc1arke/sonarqube-community-branch-plugin --branch ${SONAR_BRANCH_PLUGIN_BRANCH} \
    && cd sonarqube-community-branch-plugin \
    && ./gradlew build

FROM sonarqube:8.3.1-community

ARG SONAR_LP_VERSION=8.3.1
ARG SONAR_BRANCH_PLUGIN_VERSION=1.2.0

ENV WEB_ZIP=https://github.com/asosnoviy/sonarqube/releases/download/LP${SONAR_LP_VERSION}/webapp.zip

USER root

WORKDIR /opt/sonarqube

RUN apk add --no-cache \ 
    curl \
    unzip \
	&& rm -rf /var/cache/apk/*

RUN curl -o webapp.zip -fsSL "$WEB_ZIP" \
	&& unzip -q webapp.zip \
    && cp -f -r webapp/* web/ \
    && rm -r webapp \
    && rm webapp.zip

RUN mkdir -p extensions/downloads

COPY --from=builder /tmp/sonarqube-community-branch-plugin/build/libs/* extensions/downloads
COPY --from=builder /tmp/sonarqube-community-branch-plugin/build/libs/* lib/common

RUN chown -R sonarqube:sonarqube extensions/downloads \
    && chown -R sonarqube:sonarqube lib/common

USER sonarqube
