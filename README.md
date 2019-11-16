# Sonarqube-for-1c-docker
Dockerfile и docker compose для Sonarqube 8 под 1C-Enterprise
Репозиторий содержит докерфайлы для версий 7.9.1 LTS и 8.0-ce-beta


## Что изменено
1. Добавлены длинные пути файлов ([Спасибо](https://github.com/asosnoviy/sonarqube "Спасибо") @asosnoviy)
2. Установлены параметры javaOpts под web, core engine и search под 1с (выше стандартных)
3. Установлен выше параметр ulimits (Для эластика)
4. Сразу установлен плагин под 1с ([Ссылка на репо](https://github.com/1c-syntax/sonar-bsl-plugin-community "Ссылка на репо")) 

## Установка
Самый простой способ установить через докер компоуз файл. Образ будет взят с хаба (8.0-ce-beta)
```docker-compose up -d```

Если хотите использовать версию 7.9.1, то:
1. Необходимо собрать образ из соответствующего докерфайла
```docker image build mysonarimage```
2. В docker-compose.yml заменить 
```image: daabramov/sonarfor1c:8.0-ce-beta``` на ```mysonarimage```
3. Поднимаем через компоуз (см верх)

# ВНИМАНИЕ
Для удачного развертывания необходимо не меньше 6гб сводобной памяти на хосте, можно контролировать параметрами -Xmx и -Xms
