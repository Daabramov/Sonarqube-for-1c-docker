#!/usr/bin/env bash
# Согласовывает плагины перед запуском SonarQube:
#   1. плагины, поставленные через Marketplace, копируются в custom-plugins (переживают смену образа);
#   2. плагины из custom-plugins раскладываются в extensions/plugins;
#   3. дубли одного плагина убираются, чтобы SonarQube не падал на "two versions of plugin".
set -euo pipefail

SONARQUBE_HOME="${SONARQUBE_HOME:-/opt/sonarqube}"
PLUGINS_DIR="${SONARQUBE_HOME}/extensions/plugins"
DOWNLOADS_DIR="${SONARQUBE_HOME}/extensions/downloads"
CUSTOM_DIR="${SONAR_CUSTOM_PLUGINS_DIR:-${SONARQUBE_HOME}/extensions/custom-plugins}"
BUNDLED_LIST="${SONARQUBE_HOME}/docker/bundled-plugins.txt"
# true — пользовательская версия плагина побеждает встроенную в образ
ALLOW_OVERRIDE="${SONAR_PLUGINS_ALLOW_OVERRIDE:-false}"

log() { echo "[sync-plugins] $*"; }

is_bundled() {
  [ -f "$BUNDLED_LIST" ] && grep -qxF "$1" "$BUNDLED_LIST"
}

# Ключ плагина: из MANIFEST, если доступен unzip, иначе из имени файла.
plugin_key() {
  local jar="$1" key=""
  if command -v unzip >/dev/null 2>&1; then
    key="$(unzip -p "$jar" META-INF/MANIFEST.MF 2>/dev/null \
      | tr -d '\r' | sed -nE 's/^Plugin-Key: *(.+)$/\1/p' | head -1)"
  fi
  if [ -z "$key" ]; then
    key="$(basename "$jar" | sed -E 's/-[0-9][0-9.]*(-[A-Za-z0-9.]+)?\.jar$//')"
  fi
  echo "$key"
}

mkdir -p "$PLUGINS_DIR"

# Готовим хранилище плагинов. Том может достаться от контейнера, работавшего под другим
# uid, поэтому не полагаемся на права из образа, а чиним их на месте: chmod сработает,
# если мы владелец, а g+rwx выручает, когда uid другой, но группа общая (gid 0).
if ! mkdir -p "$CUSTOM_DIR" 2>/dev/null; then
  log "не удалось создать $CUSTOM_DIR"
fi
if [ -d "$CUSTOM_DIR" ] && [ ! -w "$CUSTOM_DIR" ]; then
  chmod u+rwx,g+rwx "$CUSTOM_DIR" 2>/dev/null || true
fi
if [ -d "$CUSTOM_DIR" ] && [ ! -w "$CUSTOM_DIR" ]; then
  log "ВНИМАНИЕ: $CUSTOM_DIR недоступен на запись под uid $(id -u):$(id -g)."
  log "Плагины будут работать, но НЕ переживут смену версии образа."
  log "Почините владельца тома: docker run --rm -v <том>:/p alpine chown -R 1000:0 /p"
fi

# 1. Сохраняем плагины, доустановленные внутри контейнера, в пользовательский каталог.
# Смотрим и downloads: плагин из Marketplace лежит там до того, как SonarQube при старте
# перенесёт (именно перенесёт, не скопирует) его в plugins.
if [ -d "$CUSTOM_DIR" ] && [ -w "$CUSTOM_DIR" ]; then
  for jar in "$DOWNLOADS_DIR"/*.jar "$PLUGINS_DIR"/*.jar; do
    [ -e "$jar" ] || continue
    name="$(basename "$jar")"
    if ! is_bundled "$name" && [ ! -e "$CUSTOM_DIR/$name" ]; then
      cp -f "$jar" "$CUSTOM_DIR/$name"
      log "сохранён в custom-plugins: $name"
    fi
  done
fi

# 2. Раскладываем пользовательские плагины в рабочий каталог.
if [ -d "$CUSTOM_DIR" ]; then
  for jar in "$CUSTOM_DIR"/*.jar; do
    [ -e "$jar" ] || continue
    name="$(basename "$jar")"
    # Плагин ждёт установки из Marketplace: не подкладываем свою копию, иначе перенос
    # из downloads упадёт на "Fail to move plugin" — SonarQube поставит его сам.
    if [ -e "$DOWNLOADS_DIR/$name" ]; then
      log "$name ставится из Marketplace — пропускаем"
      continue
    fi
    cp -f "$jar" "$PLUGINS_DIR/"
  done
fi

# 3. Оставляем по одной версии каждого плагина: иначе SonarQube не стартует.
index="$(mktemp)"
trap 'rm -f "$index"' EXIT
for jar in "$PLUGINS_DIR"/*.jar; do
  [ -e "$jar" ] || continue
  name="$(basename "$jar")"
  ver="$(echo "$name" | sed -E 's/^.*-([0-9][0-9.]*(-[A-Za-z0-9.]+)?)\.jar$/\1/')"
  bundled=false
  is_bundled "$name" && bundled=true
  printf '%s\t%s\t%s\t%s\n' "$(plugin_key "$jar")" "$ver" "$bundled" "$name" >> "$index"
done

for key in $(cut -f1 "$index" | sort -u); do
  rows="$(awk -F'\t' -v k="$key" '$1 == k' "$index")"
  [ "$(printf '%s\n' "$rows" | wc -l)" -gt 1 ] || continue

  # Версия из образа рассчитана на эту версию SonarQube, поэтому она побеждает
  # пользовательскую; SONAR_PLUGINS_ALLOW_OVERRIDE=true меняет правило на "новее — главнее".
  candidates="$rows"
  if [ "$ALLOW_OVERRIDE" != "true" ]; then
    bundled_rows="$(printf '%s\n' "$rows" | awk -F'\t' '$3 == "true"')"
    [ -n "$bundled_rows" ] && candidates="$bundled_rows"
  fi
  winner="$(printf '%s\n' "$candidates" | sort -t"$(printf '\t')" -k2,2V | tail -1 | cut -f4)"

  printf '%s\n' "$rows" | cut -f4 | while read -r name; do
    [ "$name" = "$winner" ] && continue
    rm -f "$PLUGINS_DIR/$name"
    log "плагин $key: оставлен $winner, удалён $name"
  done
done

# Передаём управление штатному entrypoint образа.
for candidate in "${SONARQUBE_HOME}/docker/entrypoint.sh" "${SONARQUBE_HOME}/bin/run.sh"; do
  if [ -x "$candidate" ]; then
    exec "$candidate" "$@"
  fi
done
exec "$@"
