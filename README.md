# Sonarqube-for-1c-docker

Dockerfile и docker compose для Sonarqube 8 под 1C-Enterprise
Репозиторий содержит докерфайл для версии 8-community до версии 8.5.1 включительно
Версия sonarqube выше версии 8.5.1 пока не поддерживается из-за отсутствия sonarqube-community-branch-plugin подходящей версии

## Что изменено

1. Установлен sonarqube-community-branch-plugin ([Ссылка на репо](https://github.com/mc1arke/sonarqube-community-branch-plugin "Ссылка на репо"))
2. Установлены параметры javaOpts под web, core engine и search под 1с
3. Установлен параметр ulimits (Для эластика)
4. Установлен sonar-bsl-plugin-community ([Ссылка на репо](https://github.com/1c-syntax/sonar-bsl-plugin-community "Ссылка на репо"))

## Версии плагинов

sonar-bsl-plugin-community - 1.8.1

sonarqube-community-branch-plugin - 1.6.0

## Установка

Самый простой способ установить через докер компоуз. Образ будет взят с хаба (8.5.1-community)

```docker-compose up -d```

Если хотите использовать другую версию sonarqube, то:

1. Соберите свой докерфайл на основании текущего
В шапке докерфайла можно указать необходимые вам версии sonarqube и плагинов.
2. Соберите образ из вашего докерфайла на основании текущего.
```docker image build -t mysonarimage -f .\8.5.1-community.Dockerfile .```
3. В docker-compose.yml заменить
```image: daabramov/sonarfor1c:8.5.1-community``` на ```image: mysonarimage```
4. Запускаем через компоуз
```docker-compose up -d```

## ВНИМАНИЕ

Для удачного развертывания необходимо не меньше 6гб сводобной памяти на хосте.
Общий объем можно контролировать параметрами -Xmx и -Xms в compose

## Известные ошибки

1. При работе Docker в ОС Windows на базе WSL2 при старте контейнера может появится ошибка:

```vm.max_map_count 65530 is too low```

Для решение проблемы необходимо:

- Зайти в консоль (cmd, powershell)
- Выполнить следующие команды:

```wsl --shutdown```

```wsl -d docker-desktop```

```sysctl -w vm.max_map_count=262144```
```sysctl -w fs.file-max=65536```

- Выйти из терминала wsl

- Перезапустить Docker Desktop
