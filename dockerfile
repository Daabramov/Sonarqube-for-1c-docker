FROM sonarqube:8.0-community-beta
ARG BSL_PLUGIN_VERSION=1.2.0
ARG SONAR_LP_VERSION=0.0.2
ENV PLUGIN=https://github.com/1c-syntax/sonar-bsl-plugin-community/releases/download/v${BSL_PLUGIN_VERSION}/sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar \
	WEB_ZIP=https://github.com/asosnoviy/sonarqube/releases/download/LP${SONAR_LP_VERSION}/webapp.zip
USER root
RUN cd /opt/sq/ \
	&& curl -o webapp.zip -fsSL "$WEB_ZIP" \
	&& unzip -q webapp.zip \
    && cp -f -r webapp/* web/ \
    && rm -r webapp \
    && rm webapp.zip \
	&& curl -o sonar-communitybsl-plugin-1.2.0.jar -fsSL "$PLUGIN" \
	&& mv -f sonar-communitybsl-plugin-1.2.0.jar extensions/plugins/
USER sonarqube