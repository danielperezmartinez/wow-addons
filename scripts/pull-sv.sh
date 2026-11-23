#!/usr/bin/env bash
# Copia el SavedVariables de un addon desde WTF/ a results/ (no versionado) para analizarlo.
#
#   scripts/pull-sv.sh [Addon]          (por defecto: ProbeAuras)
#
# Usa las mismas carpetas AddOns que link.sh; WTF está en <AddOns>/../../WTF.
# Los SavedVariables se escriben al hacer /reload, salir del personaje o cerrar el juego.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:-ProbeAuras}"
OUT="$REPO/results"
mkdir -p "$OUT"

dirs=()
if [[ -n "${WOW_ADDONS_DIRS:-}" ]]; then
  IFS=':' read -r -a dirs <<<"$WOW_ADDONS_DIRS"
elif [[ -f "$REPO/.wow-addons-path" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"; line="${line%"${line##*[![:space:]]}"}"
    [[ -n "$line" ]] && dirs+=("$line")
  done <"$REPO/.wow-addons-path"
fi
[[ ${#dirs[@]} -gt 0 ]] || { echo "Configura .wow-addons-path primero (ver scripts/link.sh)." >&2; exit 1; }

found=0
for dest in "${dirs[@]}"; do
  wtf="$(cd "$dest/../.." 2>/dev/null && pwd)/WTF"
  flavor="$(basename "$(dirname "$wtf")")"   # _retail_, _forever_, ...
  [[ -d "$wtf/Account" ]] || { echo "Sin WTF/Account en $wtf"; continue; }
  while IFS= read -r -d '' f; do
    account="$(basename "$(dirname "$(dirname "$f")")")"
    cp "$f" "$OUT/${NAME}${flavor}${account}.lua"
    echo "copiado: $f -> results/${NAME}${flavor}${account}.lua"
    found=1
  done < <(find "$wtf/Account" -path "*/SavedVariables/$NAME.lua" -print0)
done
[[ $found -eq 1 ]] || echo "No se encontró $NAME.lua en ningún WTF. ¿Hiciste /reload o saliste del juego?"
