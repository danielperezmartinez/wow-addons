# wow-addons

Addons propios para **WoW Forever** (cliente moderno, API de Midnight con *secret values*).
Solo API del juego: nada de lectores de memoria ni automatización de entradas.

## Estructura

```
addons/<Addon>/      un addon por carpeta (.toc + .lua), se enlaza tal cual en Interface/AddOns
scripts/link.sh      crea/quita/comprueba los symlinks en Interface/AddOns
scripts/pull-sv.sh   copia los SavedVariables de un addon a results/ para analizarlos
docs/                notas de la API y guías de prueba
```

Normas obligatorias (anti-baneo): [docs/normas.md](docs/normas.md).

Addons:

- `ProbeAuras` — sonda **desechable** para ver qué devuelven auras y cooldowns dentro y fuera de combate. Guía: [docs/prueba-probeauras.md](docs/prueba-probeauras.md).

## Enlazar con el juego

El juego está en otro PC con **Windows**; aquí (Linux) se escribe y se comprueba la sintaxis. En el PC de
juego hay un clon del repo y los addons se enlazan desde él.

**Windows** (junctions, no hace falta administrador):

1. Opcional: crea `.wow-addons-path` en la raíz del clon con la ruta de `Interface\AddOns`, una por línea.
   Sin él se usan `C:\Program Files (x86)\World of Warcraft\_retail_` y `\_forever_` si existen.
2. `powershell -ExecutionPolicy Bypass -File scripts\link.ps1` (enlaza todos); `... link.ps1 status`;
   `... link.ps1 unlink ProbeAuras`. Resultados: `scripts\pull-sv.ps1`.

**Linux/Wine** (si algún día se juega aquí): igual con `scripts/link.sh` y `scripts/pull-sv.sh` (symlinks;
Wine los sigue). `.wow-addons-path` es obligatorio. Ejecútalos desde el checkout principal.

## .toc

- Interface de Forever: `16001`. Midnight (retail): `120105` (12.1.5). Un mismo `.toc` puede listar varios: `## Interface: 16001, 120105`.
- Sufijos: `_Forever.toc` (alias de `_Camelot.toc`) solo Forever; `_Standard.toc` solo Midnight; `_Mainline.toc` ambos.
  Ver [docs/notas-api-midnight.md](docs/notas-api-midnight.md).

## Editor

VS Code con las extensiones recomendadas (`.vscode/extensions.json`): **WoW API** de Ketho (`ketho.wow-api`, trae
las anotaciones de la API) y Lua de LuaLS. `.luarc.json` fija Lua 5.1 y los globales propios.
Comprobación rápida de sintaxis sin juego: `luac5.1 -p addons/*/*.lua`.
