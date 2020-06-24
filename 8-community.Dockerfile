FROM sonarqube:8-community
ARG BSL_PLUGIN_VERSION=1.6.1
ARG SONAR_LP_VERSION=0.0.2
ARG SONAR_BRANCH_PLUGIN_VERSION=1.3.1

ENV PLUGIN=https://github.com/1c-syntax/sonar-bsl-plugin-community/releases/download/v${BSL_PLUGIN_VERSION}/sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar \
    PLUGIN_NAME=sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar	\ 
	WEB_ZIP=https://github.com/asosnoviy/sonarqube/releases/download/LP${SONAR_LP_VERSION}/webapp.zip \
	SONAR_BRANCH_PLUGIN_JAR=https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${SONAR_BRANCH_PLUGIN_VERSION}/sonarqube-community-branch-plugin-${SONAR_BRANCH_PLUGIN_VERSION}.jar \
	SONAR_BRANCH_PLUGIN_FILENAME=sonarqube-community-branch-plugin.jar

USER root

RUN apk add curl

RUN cd /opt/sonarqube/ \
	&& curl -o webapp.zip -fsSL "$WEB_ZIP" \
	&& unzip -q webapp.zip \
    && cp -f -r webapp/* web/ \
    && rm -r webapp \
    && rm webapp.zip \
	&& curl -o "$PLUGIN_NAME" -fsSL "$PLUGIN" \
	&& mv -f "$PLUGIN_NAME" extensions/plugins/

RUN cd /opt/sonarqube/ \
    && curl -o "$SONAR_BRANCH_PLUGIN_FILENAME" -fsSL "$SONAR_BRANCH_PLUGIN_JAR" \
    && mkdir -p extensions/plugins \
    && cp -f "$SONAR_BRANCH_PLUGIN_FILENAME" extensions/plugins \
    && cp -f "$SONAR_BRANCH_PLUGIN_FILENAME" lib/common \
    && chown sonarqube:sonarqube "extensions/plugins/$SONAR_BRANCH_PLUGIN_FILENAME" \
    && chown sonarqube:sonarqube "lib/common/$SONAR_BRANCH_PLUGIN_FILENAME" \
    && rm "$SONAR_BRANCH_PLUGIN_FILENAME"

USER sonarqube
