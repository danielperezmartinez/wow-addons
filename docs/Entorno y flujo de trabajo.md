# Entorno y flujo de trabajo

Detalle práctico de cómo se trabaja en este repo. Las reglas están en
[[README#2. Entorno de trabajo]] y [[README#4. Publicación y despliegue]]; esta nota
explica el porqué y los escollos conocidos.

## Dos PC

- **PC de desarrollo (Linux)**: aquí vive el repo; no hay WoW (se buscó en Steam,
  Lutris, Bottles, Heroic y las carpetas de juegos habituales: no está).
- **PC de juego (Windows)**: Forever en `World of Warcraft\_forever_\`. Sin
  herramientas de desarrollo ni clon del repo, y el usuario no quiere instalarle
  ninguna.

## Ida: del repo al juego

- Los addons llegan como `.zip` de la release
  [`latest`](https://github.com/danielperezmartinez/wow-addons/releases/latest), que
  se descarga **sin iniciar sesión**. Los *artifacts* de Actions no sirven: piden
  sesión y caducan.
- La release la regenera el job `Publicar` de `ci.yml` al llegar a `main` un cambio
  en `addons/`, o a mano desde Actions.
- Antes, con `package.yml` y su filtro `paths`, el primer push de `main` no lo
  disparó (el filtro no salta al crear la rama). `ci.yml` no usa `paths`: decide
  con un diff y, si no puede calcularlo, publica.
- `scripts/link.*` y `scripts/pull-sv.*` existen para jugar con un clon en la misma
  máquina, pero en la práctica **no se usan**.

## Vuelta: del juego al repo

- Los SavedVariables (`World of Warcraft\_forever_\WTF\Account\<CUENTA>\SavedVariables\<Addon>.lua`)
  se guardan con `/reload` y el usuario los trae a mano al PC de desarrollo
  (normalmente a su carpeta de descargas).
- Se copian a `results/` del checkout principal, que no se versiona: llevan el
  nombre de la cuenta y de los personajes. Nunca se suben ni se pegan en la bóveda.

## Herramientas en el PC de desarrollo

- Hay `lua5.1`, `luac5.1` y `luajit`.
- No hay VS Code, `luacheck`, `stylua` ni `lua-language-server`; `python3` no tiene
  PyYAML (para validar YAML, dejar que lo haga el CI o pedir permiso para una
  herramienta).
- gitleaks está instalado; los hooks se activan con
  `git config core.hooksPath .githooks` en el checkout principal.

## Escollos para agentes (worktrees)

- `EnterWorktree` necesita al menos un commit en el repo.
- En una sesión aislada en un worktree, la guarda de Claude Code rechaza `git -C`
  hacia el checkout principal, `git -c core.hooksPath=…`, `rebase --exec`, `git
  config` que toque la configuración compartida y los comandos compuestos que
  mezclan `cd`, bucles o tuberías con git: hay que partirlos en órdenes simples.
  `core.hooksPath` se fija desde el checkout principal (la configuración es
  compartida): a partir de ahí los hooks corren solos también en los worktrees. Si
  aún no está fijado, ejecutarlos a mano antes de cada commit
  (`sh .githooks/pre-commit`, `sh .githooks/commit-msg <fichero>`) y pedir al
  usuario que lo fije, o fijarlo tras salir del worktree.
- Para integrar: salir del worktree, `git merge --ff-only <rama>` en `main` y, con
  el OK del usuario, push.

## Cómo escribir guías de prueba en el juego

Lecciones de [[prueba-probeauras]]:

- Rutas de Windows completas y pasos numerados; qué copiar y dónde dejarlo.
- Si hay un panel de la sonda, decir explícitamente que **no es en vivo**: solo
  cambia con cada foto (`snap`). El usuario lo confundió con el gestor de
  cooldowns y esperaba verlo moverse.
- Las acciones "dentro de combate" se piden **mientras se pega al muñeco**, no
  antes ni después: el usuario hizo `/probe snap dentro` fuera de combate.
- Pedir al final una frase sobre qué se veía, además del fichero.
