[![Docker Image CI](https://github.com/Daabramov/Sonarqube-for-1c-docker/actions/workflows/docker-image.yml/badge.svg?branch=master)](https://github.com/Daabramov/Sonarqube-for-1c-docker/actions/workflows/docker-image.yml)
# Sonarqube-for-1c-docker

Dockerfile и docker compose для Sonarqube 26.5 под 1C-Enterprise

## Что изменено по сравнению с стандартной версией

1. Установлен sonarqube-community-branch-plugin ([Ссылка на репо](https://github.com/mc1arke/sonarqube-community-branch-plugin "Ссылка на репо"))
2. Установлены параметры javaOpts под web, core engine и search под 1с
3. Установлен параметр ulimits (Для эластика)
4. Установлен sonar-bsl-plugin-community ([Ссылка на репо](https://github.com/1c-syntax/sonar-bsl-plugin-community "Ссылка на репо"))
5. Установлен RUSSIAN PACK (Локализация)

## Версии плагинов

sonar-bsl-plugin-community - 1.18.1

sonarqube-community-branch-plugin - 26.5.0

sonar-l10n-ru - 25.7

## Свои плагины

Всё, что лежит в `/opt/sonarqube/extensions/custom-plugins`, переживает смену версии образа. Плагины туда попадают двумя путями, и оба равноправны:

* **Руками** — просто положите jar в хранилище, ничего вписывать в Dockerfile не нужно. Плагин необязательно должен быть из Marketplace.
* **Через Marketplace** — jar сохранится в хранилище автоматически. Marketplace кладёт его в `extensions/downloads` и просит перезапустить SonarQube; на этом перезапуске плагин копируется в хранилище, а установку доделывает сам SonarQube.

При каждом старте плагины из хранилища возвращаются в рабочий каталог `extensions/plugins`.

Чем монтировать хранилище — решаете вы. В `docker-compose.yml` по умолчанию именованный том `sonarqube_plugins`, но если хотите видеть jar-ы в файловой системе и класть их обычным `cp`, замените строку на каталог с хоста:

```yaml
- ./plugins:/opt/sonarqube/extensions/custom-plugins
```

Права entrypoint чинит сам, если может; если нет — напишет в лог, что именно сделать. На Linux каталог, созданный докером автоматически, принадлежит root — тогда сделайте `mkdir -p plugins && chown 1000:0 plugins` до первого старта.

Чтобы удалить плагин насовсем, уберите его jar из хранилища — иначе следующий старт вернёт его обратно. Для именованного тома посмотреть и почистить содержимое можно так:

```bash
docker run --rm -v sonarqube_plugins:/p alpine sh -c 'ls /p && rm /p/имя-плагина.jar'
```

Если один и тот же плагин есть и в образе, и в хранилище (типичная ситуация после апгрейда: в образе новый `sonar-bsl-plugin-community`, а в томе лежит старый), побеждает версия из образа — она собрана под эту версию SonarQube. Лишний jar удаляется из рабочего каталога, а в логе контейнера будет строка вида:

```
[sync-plugins] плагин sonar-communitybsl-plugin: оставлен sonar-communitybsl-plugin-1.18.1.jar, удалён sonar-communitybsl-plugin-1.15.0.jar
```

Старый jar при этом остаётся в хранилище (на случай отката образа). Если вам нужна именно своя версия плагина вместо встроенной, задайте в compose `SONAR_PLUGINS_ALLOW_OVERRIDE=true` — тогда выигрывает более новая версия.

Каталог `/opt/sonarqube/extensions` монтировать томом нельзя: том перекроет плагины из образа, и после апгрейда вы получите старые версии. Поэтому том подключается только к `extensions/custom-plugins`.

Что это НЕ решает: плагин, несовместимый с новой версией SonarQube, так и останется несовместимым — сохранение jar-а не делает его новее. Плагины из образа (bsl, локализация) обновляются вместе с образом, а вот поставленные через Marketplace после крупного апгрейда может потребоваться обновить там же. Если сонар после апгрейда не стартует, смотрите в логе жалобы на конкретный плагин и обновите или удалите его.

## Обновление до 25.5 (ВАЖНО)

В версии 25.5 подняты требования к postgresql было (11-17), стало (13-17).
Перед обновлением на эту версию выполните миграцию на новую версию, сделать это можно через https://github.com/pgautoupgrade/docker-pgautoupgrade
ОБЯЗАТЕЛЬНО ДЕЛАЙТЕ БЕКАПЫ перед обновлением!

## Установка

Самый простой способ установить через докер компоуз. Образ будет взят с хаба.

```docker-compose up -d```

Если хотите использовать другую версию sonarqube, то:

1. Соберите свой докерфайл на основании текущего
В шапке докерфайла можно указать необходимые вам версии sonarqube и плагинов.
1. Соберите образ из вашего докерфайла на основании текущего.
```docker image build -t mysonarimage -f .\26.5-community.Dockerfile .```
1. В docker-compose.yml заменить
```image: daabramov/sonarfor1c:26.5-community``` на ```image: mysonarimage```
1. Запускаем через компоуз
```docker-compose up -d```

## ВНИМАНИЕ

Для удачного развертывания необходимо не меньше 6гб сводобной памяти на хосте.
Общий объем можно контролировать параметрами -Xmx и -Xms в compose

## Общая информация
1) Логин пароль для входа по-умолчанию ```admin:admin```
2) Вход в сонар происходит по адресу ```http://localhost:32772``` *(порт по умолчанию из docker-compose)*
3) Желательно поменять логин и пароль ```docker-compose``` с ```sonar:sonar``` на ваши новые (см environments ```POSTGRES_USER, POSTGRES_PASSWORD, SONARQUBE_JDBC_USERNAME, SONARQUBE_JDBC_PASSWORD```)

## Если Sonar не запускается

### При работе docker под WSL2

```
В каталоге пользователя %userprofile% ( C:\Users\<username>) создать или изменить файл .wslconfig. Добавить следующее содержимое:
```

```
[wsl2]
kernelCommandLine = "sysctl.vm.max_map_count=262144"
```

Далее выполнить перезагрузку докер и wsl.

### В Linux
При использовании Linux на хосте докера достаточно выполнить команду

```echo "vm.max_map_count=262144" >> /etc/sysctl.conf```

```echo "sysctl -w fs.file-max=65536" >> /etc/sysctl.conf```
