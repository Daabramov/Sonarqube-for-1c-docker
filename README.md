# Sonarqube-for-1c-docker
Dockerfile и docker compose для Sonarqube 8 под 1C-Enterprise

## Что изменено
1. Добавлены длинные пути файлов ([Спасибо](https://github.com/asosnoviy/sonarqube "Спасибо") @asosnoviy)
2. Установлены параметры javaOpts под web, core engine и search под 1с (выше стандартных)
3. Установлен выше параметр ulimits (Для эластика)
4. Сразу установлен плагин под 1с ([Ссылка на репо](https://github.com/1c-syntax/sonar-bsl-plugin-community "Ссылка на репо")) 

# ВНИМАНИЕ
Для удачного развертывания необходимо не меньше 6гб сводобной памяти на хосте, можно контролировать параметрами -Xmx и -Xms
