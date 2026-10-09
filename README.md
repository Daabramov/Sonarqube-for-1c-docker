[![Docker Image CI](https://github.com/Daabramov/Sonarqube-for-1c-docker/actions/workflows/docker-image.yml/badge.svg?branch=master)](https://github.com/Daabramov/Sonarqube-for-1c-docker/actions/workflows/docker-image.yml)

> [!WARNING]
> ## 📦 Проект архивирован
>
> Репозиторий больше **не поддерживается**: новых образов `daabramov/sonarfor1c` не будет, issue и PR не принимаются.
> Уже опубликованные образы остаются на Docker Hub и продолжат работать, но обновлений (в том числе безопасности) для них не будет.

### Почему

Поддерживать отдельный образ больше нет смысла:

- **Branch-плагин** — автор [sonarqube-community-branch-plugin](https://github.com/mc1arke/sonarqube-community-branch-plugin) сам публикует готовый образ SonarQube с уже подключённым плагином: [`mc1arke/sonarqube-with-community-branch-plugin`](https://hub.docker.com/r/mc1arke/sonarqube-with-community-branch-plugin). Этот репозиторий и так собирался поверх него, поэтому новые версии всё равно зависели от его обновлений.
- **Остальные плагины** (поддержка 1С/BSL — [sonar-bsl-plugin-community](https://github.com/1c-syntax/sonar-bsl-plugin-community), русская локализация) ставятся в пару кликов из встроенного **Marketplace** SonarQube.

### Что делать

1. **Сделайте бэкап** базы PostgreSQL (и тома `sonarqube_data`) перед любыми изменениями.
2. В `docker-compose.yml` замените образ:

   ```yaml
   # было
   image: daabramov/sonarfor1c:26.5-community
   # стало
   image: mc1arke/sonarqube-with-community-branch-plugin:26.5.0.122743-community
   ```

   Это тот же базовый образ, на котором был собран последний `daabramov/sonarfor1c:26.5-community`. Более новые теги — на [Docker Hub](https://hub.docker.com/r/mc1arke/sonarqube-with-community-branch-plugin/tags). Версия SonarQube не должна быть ниже той, что у вас стоит сейчас.
3. **Включите том для плагинов**, иначе плагины из Marketplace пропадут при пересоздании контейнера — раскомментируйте строку в секции `volumes` сервиса `sonar`:

   ```yaml
   volumes:
     - sonarqube_conf:/opt/sonarqube/conf
     - sonarqube_data:/opt/sonarqube/data
     - sonarqube_extensions:/opt/sonarqube/extensions
   ```

   > ⚠️ Branch-плагин в образе mc1arke тоже лежит в `extensions/plugins`. При переходе на **новый** тег образа удалите из тома старый `sonarqube-community-branch-plugin-*.jar` (или пересоздайте том `sonarqube_extensions` и заново поставьте плагины из Marketplace), иначе останется старая версия плагина.

4. Пересоздайте контейнер: `docker-compose pull && docker-compose up -d`.
5. Зайдите в SonarQube под администратором → **Administration → Marketplace**, подтвердите риски установки сторонних плагинов и установите:
   - **1C (BSL) Community Plugin**
   - **Russian Pack** (по желанию)

   После установки нажмите **Restart Server**.

   Если Marketplace недоступен (закрытый контур без интернета) — скачайте `.jar` из релизов [sonar-bsl-plugin-community](https://github.com/1c-syntax/sonar-bsl-plugin-community/releases) и [sonar-l10n-ru](https://github.com/1c-syntax/sonar-l10n-ru/releases) и положите их в том `sonarqube_extensions` в каталог `plugins/`, затем перезапустите контейнер.
6. Настройки памяти (`SONAR_*_JAVAOPTS`), `ulimits` и подсказки из раздела «Если Sonar не запускается» (в старой документации ниже) по-прежнему актуальны — их можно оставить как есть.

Спасибо всем, кто пользовался образом! 🙏

---

<details>
<summary>Старая документация (для справки)</summary>

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

</details>
