FROM mc1arke/sonarqube-with-community-branch-plugin:26.5.0.122743-community

ARG RUSSIAN_PACK=25.7
ARG BSL_PLUGIN_VERSION=1.18.1

USER root

WORKDIR /opt/sonarqube

# plugins
# Владелец — sonarqube:root (uid 1000, gid 0): группы sonarqube в образе нет.
ADD --chown=sonarqube:root https://github.com/1c-syntax/sonar-l10n-ru/releases/download/v${RUSSIAN_PACK}/sonar-l10n-ru-plugin-${RUSSIAN_PACK}.jar extensions/plugins
ADD --chown=sonarqube:root https://github.com/1c-syntax/sonar-bsl-plugin-community/releases/download/v${BSL_PLUGIN_VERSION}/sonar-communitybsl-plugin-${BSL_PLUGIN_VERSION}.jar extensions/plugins

# Список плагинов, входящих в образ. Всё, чего в нём нет, считается плагином пользователя.
RUN ls -1 extensions/plugins/*.jar | xargs -n1 basename > docker/bundled-plugins.txt \
    && install -d -o sonarqube -g root -m 0770 extensions/custom-plugins

COPY --chown=sonarqube:root --chmod=755 docker/sync-plugins.sh docker/sync-plugins.sh

USER sonarqube

ENTRYPOINT ["/opt/sonarqube/docker/sync-plugins.sh"]
