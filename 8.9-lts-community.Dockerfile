FROM mc1arke/sonarqube-with-community-branch-plugin:lts

ARG BSL_PLUGIN_VERSION=1.8.1

ENV PLUGIN=https://github.com/1c-syntax/sonar-bsl-plugin-community/releases/download/v${BSL_PLUGIN_VERSION}/sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar \
    PLUGIN_NAME=sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar

USER root

WORKDIR /opt/sonarqube

RUN apk add --no-cache \ 
    curl \
    unzip \
	&& rm -rf /var/cache/apk/*

RUN curl -o "$PLUGIN_NAME" -fsSL "$PLUGIN" \
    && mv -f "$PLUGIN_NAME" extensions/plugins/

USER sonarqube
