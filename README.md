[![Docker Image CI](https://github.com/Daabramov/Sonarqube-for-1c-docker/actions/workflows/docker-image.yml/badge.svg?branch=master)](https://github.com/Daabramov/Sonarqube-for-1c-docker/actions/workflows/docker-image.yml)
# Sonarqube-for-1c-docker

Dockerfile и docker compose для Sonarqube 10 под 1C-Enterprise

## Что изменено по сравнению с стандартной версией

1. Установлен sonarqube-community-branch-plugin ([Ссылка на репо](https://github.com/mc1arke/sonarqube-community-branch-plugin "Ссылка на репо"))
2. Установлены параметры javaOpts под web, core engine и search под 1с
3. Установлен параметр ulimits (Для эластика)
4. Установлен sonar-bsl-plugin-community ([Ссылка на репо](https://github.com/1c-syntax/sonar-bsl-plugin-community "Ссылка на репо"))
5. Установлен RUSSIAN PACK (Локализация)

## Версии плагинов

sonar-bsl-plugin-community - 1.15.0

sonarqube-community-branch-plugin - 1.18.0

sonar-l10n-ru - 10.4

## Обновление до 9.9 (ВАЖНО)

В 9.9+ убраны старые env, если вы использовали шаблон docker-compose из этого репозитория, то обратите внимание на переименования при подключении Postgresql

## Установка

Самый простой способ установить через докер компоуз. Образ будет взят с хаба.

```docker-compose up -d```

Если хотите использовать другую версию sonarqube, то:

1. Соберите свой докерфайл на основании текущего
В шапке докерфайла можно указать необходимые вам версии sonarqube и плагинов.
1. Соберите образ из вашего докерфайла на основании текущего.
```docker image build -t mysonarimage -f .\10.4-community.Dockerfile .```
1. В docker-compose.yml заменить
```image: daabramov/sonarfor1c:10.4-community``` на ```image: mysonarimage```
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
