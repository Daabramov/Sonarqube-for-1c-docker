# Sonarqube-for-1c-docker
Dockerfile и docker compose для Sonarqube 8 под 1C-Enterprise
Репозиторий содержит докерфайл для версии 8-community.
Версия sonarqube выше 8 версии пока не поддерживается из-за отсутствия sonarqube-community-branch-plugin подходящей версии


## Что изменено
1. Добавлены длинные пути файлов ([Спасибо](https://github.com/asosnoviy/sonarqube "Спасибо") @asosnoviy)
2. Установлены параметры javaOpts под web, core engine и search под 1с
3. Установлен параметр ulimits (Для эластика)
4. Установлен sonar-bsl-plugin-community ([Ссылка на репо](https://github.com/1c-syntax/sonar-bsl-plugin-community "Ссылка на репо")) 
5. Установлен sonarqube-community-branch-plugin ([Ссылка на репо](https://github.com/mc1arke/sonarqube-community-branch-plugin "Ссылка на репо")) 

## Версии плагинов:

sonar-bsl-plugin-community - 1.6.1

sonarqube-community-branch-plugin - 1.3.1

## Установка
Самый простой способ установить через докер компоуз. Образ будет взят с хаба (8-community)

```docker-compose up -d```

Если хотите использовать другую версию sonarqube, то:
1. Соберите свой докерфайл на основании текущего.

В шапке докерфайла можно указать необходимые вам версии sonarqube и плагинов.

2. Соберите образ из вашего докерфайла на основании текущего.

```docker image build -t mysonarimage -f .\8.3.1-community.Dockerfile .```

3. В docker-compose.yml заменить 
```image: daabramov/sonarfor1c:8-community``` на ```image: mysonarimage```

4. Запускаем через компоуз

```docker-compose up -d```

## ВНИМАНИЕ
Для удачного развертывания необходимо не меньше 6гб сводобной памяти на хосте.
Общий объем можно контролировать параметрами -Xmx и -Xms в compose

## Известные ошибки
1. При работе Docker в ОС Windows на базе WSL2 при старте контейнера может появится ошибка:
```vm.max_map_count 65530 is too low```

Для решение проблемы необходимо:
- Остановить Docker Desktop
- Зайти в консоль (cmd, powershell)
- Выполнить следующие команды:
```wsl -d docker-desktop```
```sysctl -w vm.max_map_count=262144```
```wsl --shutdown```
- Запустить Docker Desktop