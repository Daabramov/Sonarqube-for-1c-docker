# Sonarqube-for-1c-docker

Dockerfile и docker compose для Sonarqube 8 под 1C-Enterprise
Репозиторий содержит докерфайл для версии 8-community версии 8.9 LTS


## Что изменено по сравнению с стандартной версией

1. Установлен sonarqube-community-branch-plugin ([Ссылка на репо](https://github.com/mc1arke/sonarqube-community-branch-plugin "Ссылка на репо"))
2. Установлены параметры javaOpts под web, core engine и search под 1с
3. Установлен параметр ulimits (Для эластика)
4. Установлен sonar-bsl-plugin-community ([Ссылка на репо](https://github.com/1c-syntax/sonar-bsl-plugin-community "Ссылка на репо"))
5. Установлен RUSSIAN PACK (Локализация)

## Версии плагинов

sonar-bsl-plugin-community - 1.9.0

sonarqube-community-branch-plugin - 1.8.0

## Установка

Самый простой способ установить через докер компоуз. Образ будет взят с хаба (8.9-lts-community)

```docker-compose up -d```

Если хотите использовать другую версию sonarqube, то:

1. Соберите свой докерфайл на основании текущего
В шапке докерфайла можно указать необходимые вам версии sonarqube и плагинов.
2. Соберите образ из вашего докерфайла на основании текущего.
```docker image build -t mysonarimage -f .\8.9-lts-community.Dockerfile .```
3. В docker-compose.yml заменить
```image: daabramov/sonarfor1c:8.9-lts-community``` на ```image: mysonarimage```
4. Запускаем через компоуз
```docker-compose up -d```

## ВНИМАНИЕ

Для удачного развертывания необходимо не меньше 6гб сводобной памяти на хосте.
Общий объем можно контролировать параметрами -Xmx и -Xms в compose

## Общая информация
1) Логин пароль для входа по-умолчанию ```admin:admin```
2) Вход в сонар происходит по адресу ```http://localhost:32772``` *(порт по умолчанию из docker-compose)*
3) Желательно поменять логин и пароль ```docker-compose``` с ```sonar:sonar``` на ваши новые (см environments ```POSTGRES_USER, POSTGRES_PASSWORD, SONARQUBE_JDBC_USERNAME, SONARQUBE_JDBC_PASSWORD```)

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

При работе в Linux на хосте докера достаточно выполнить команду

```echo "vm.max_map_count=262144" >> /etc/sysctl.conf```
```echo "sysctl -w fs.file-max=65536" >> /etc/sysctl.conf```
