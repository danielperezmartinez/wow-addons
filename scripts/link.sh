#!/usr/bin/env bash
# Enlaza (symlink) cada addon de addons/ en la carpeta Interface/AddOns del juego.
#
#   scripts/link.sh [link|unlink|status] [Addon ...]      (por defecto: link, todos)
#
# Carpetas AddOns de destino, por orden de prioridad:
#   1. Variable WOW_ADDONS_DIRS (varias separadas por ':')
#   2. Fichero .wow-addons-path en la raíz del repo (una ruta por línea, # comenta; no se versiona)
# Ejemplo de .wow-addons-path:
#   /home/<usuario>/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns
#
# Ejecútalo desde el checkout principal (no desde un worktree): el enlace apunta a la
# carpeta del repo en la que vive este script.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTION="${1:-link}"
[[ $# -gt 0 ]] && shift

case "$REPO" in
  */.claude/worktrees/*) echo "Aviso: estás en un worktree ($REPO); los enlaces apuntarán aquí." >&2 ;;
esac

dirs=()
if [[ -n "${WOW_ADDONS_DIRS:-}" ]]; then
  IFS=':' read -r -a dirs <<<"$WOW_ADDONS_DIRS"
elif [[ -f "$REPO/.wow-addons-path" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"; line="${line%"${line##*[![:space:]]}"}"
    [[ -n "$line" ]] && dirs+=("$line")
  done <"$REPO/.wow-addons-path"
fi
if [[ ${#dirs[@]} -eq 0 ]]; then
  echo "No hay destino. Crea $REPO/.wow-addons-path con la ruta de Interface/AddOns o exporta WOW_ADDONS_DIRS." >&2
  exit 1
fi

addons=("$@")
if [[ ${#addons[@]} -eq 0 ]]; then
  for d in "$REPO"/addons/*/; do addons+=("$(basename "$d")"); done
fi

for dest in "${dirs[@]}"; do
  if [[ ! -d "$dest" ]]; then echo "No existe: $dest (¿has abierto el juego una vez?)" >&2; continue; fi
  echo "== $dest"
  for name in "${addons[@]}"; do
    src="$REPO/addons/$name"
    tgt="$dest/$name"
    [[ -d "$src" ]] || { echo "  ? $name: no existe en addons/"; continue; }
    case "$ACTION" in
      link)
        if [[ -L "$tgt" ]]; then
          ln -sfn "$src" "$tgt"; echo "  = $name (enlace actualizado)"
        elif [[ -e "$tgt" ]]; then
          echo "  ! $name: ya existe una carpeta real; no la toco. Muévela o bórrala a mano."
        else
          ln -s "$src" "$tgt"; echo "  + $name"
        fi ;;
      unlink)
        if [[ -L "$tgt" ]]; then rm "$tgt"; echo "  - $name"; else echo "  · $name: no es un enlace, lo dejo"; fi ;;
      status)
        if [[ -L "$tgt" ]]; then echo "  ✓ $name -> $(readlink "$tgt")"
        elif [[ -e "$tgt" ]]; then echo "  ! $name: carpeta real (no enlace)"
        else echo "  ✗ $name: sin enlazar"; fi ;;
      *) echo "Acción desconocida: $ACTION (link|unlink|status)" >&2; exit 2 ;;
    esac
  done
done
