FROM mc1arke/sonarqube-with-community-branch-plugin:25.5.0.107428-community

ARG RUSSIAN_PACK=25.1
ARG BSL_PLUGIN_VERSION=1.16.1

USER root

WORKDIR /opt/sonarqube

# plugins
ADD --chown=sonarqube:sonarqube https://github.com/1c-syntax/sonar-l10n-ru/releases/download/v${RUSSIAN_PACK}/sonar-l10n-ru-plugin-${RUSSIAN_PACK}.jar extensions/plugins
ADD --chown=sonarqube:sonarqube https://github.com/1c-syntax/sonar-bsl-plugin-community/releases/download/v${BSL_PLUGIN_VERSION}/sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar extensions/plugins
USER sonarqube