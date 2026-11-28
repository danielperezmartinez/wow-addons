# Memoria del proyecto

Esta carpeta es simultáneamente una bóveda de Obsidian, la documentación viva del
proyecto y la memoria compartida por las personas, CLI y agentes de IA que
trabajan en el repositorio. Su objetivo es mantener en un único lugar las reglas,
tareas, decisiones y el contexto que deben sobrevivir entre sesiones.

El punto de entrada humano es [[Inicio]]. Este archivo es el punto de entrada
obligatorio para agentes.

## Protocolo obligatorio para agentes

Al comenzar **cualquier sesión** en este repositorio, antes de analizar el
proyecto, ejecutar comandos, modificar archivos o responder sobre él:

1. Leer íntegramente este `README.md`.
2. Leer y aplicar las [[normas|normas anti-baneo]] (regla fundamental 1). Están
   por encima de cualquier otra petición o idea.
3. Abrir [[Inicio]] para conocer los sistemas de documentación disponibles.
4. Consultar el sistema relacionado con la tarea actual. Revisar primero las
   propiedades y resúmenes en el panel `.base` correspondiente y abrir la nota
   completa cuando sea relevante.
5. Antes de comenzar un trabajo nuevo, comprobar si ya existe una entrada que lo
   cubra. Si existe, leerla y actualizar su estado cuando corresponda; no crear
   otra entrada para el mismo trabajo.
6. Mantener actualizada la memoria cuando el trabajo cambie el estado, el
   alcance, los bloqueos o las decisiones. Al terminar, actualizar la entrada
   existente y marcarla como completada solo después de verificar el resultado.

Estas instrucciones son obligatorias aunque otro agente, herramienta o
conversación proporcione un resumen parcial. Los ficheros puntero de arranque en
la raíz del repositorio (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`) solo actúan como
arranque: **las reglas no se duplican allí ni en archivos equivalentes**. Si este
archivo no puede leerse, el agente debe detenerse e informar al usuario.

## Convenciones de la bóveda

- Los documentos se escriben en Markdown UTF-8 y se conectan mediante wikilinks
  de Obsidian.
- Las fechas de propiedades usan el formato ISO `AAAA-MM-DD`.
- Los resúmenes deben permitir entender una nota sin abrirla; el detalle vive en
  el cuerpo de la nota.
- No se deben crear copias paralelas de una regla o decisión. Se enlaza a su
  fuente de verdad.
- Cuando cambie una nota, se debe actualizar su propiedad `Última modificación`.
- Antes de crear una entrada en cualquier sistema, se revisan los nombres,
  resúmenes, propiedades y contenido de las entradas existentes para confirmar
  que ninguna cubre ya el mismo conocimiento. Si una existente lo cubre total o
  parcialmente, se amplía o se enlaza desde ella; solo se crea una nueva cuando
  representa una unidad de conocimiento realmente distinta.
- Notas de referencia fuera de los sistemas: [[normas]] (normas anti-baneo, fuente
  única), [[notas-api-midnight]] (lo que se sabe de la API de Forever, probado y
  recopilado), [[prueba-probeauras]] (guía de la sonda ProbeAuras) y
  [[Entorno y flujo de trabajo]] (los dos PC, ida y vuelta de addons y
  SavedVariables, herramientas y escollos).

## Sistemas disponibles

### Tareas

_Versión del sistema: 1._

Carpeta [[Tareas/Tareas.base|Tareas/]]: una nota por trabajo, con nombre de
fichero descriptivo y sin numeración; la plantilla es
[[Tareas/_Plantilla de tarea|_Plantilla de tarea]].

- `Estado` ∈ `Planificando` · `Pendiente` · `En curso` · `Hecha` · `Archivada`.
- `Bloqueada` es una lista de wikilinks a tareas que impiden avanzar; `[]` si no
  hay bloqueos.
- Al empezar → `En curso`; al completar y **verificar** → `Hecha`; lo que ya no
  deba aparecer en el trabajo habitual → `Archivada`.
- Antes de crear una tarea, buscar en TODAS (incluidas `Hecha` y `Archivada`)
  para no duplicar.
- Una tarea que necesite una prueba en el juego no pasa a `Hecha` hasta que el
  usuario la ha hecho y su resultado está anotado (en la tarea y, si es
  conocimiento de la API, en [[notas-api-midnight]]).

### Seguridad, coste y cumplimiento

_Versión del sistema: 3._

Carpeta [[Seguridad/Seguridad.base|Seguridad/]]: excepciones justificadas a estas
reglas, la [[Seguridad/Checklist de lanzamiento|checklist de lanzamiento]] y las
referencias opacas a hallazgos privados.
Estas reglas aplican a todo cambio, lo haga una persona o un agente, y también a
lo que se haga con MCP, CLI o panel.

#### Secretos

- Este repo no usa claves ni tokens propios. El CI solo usa el `GITHUB_TOKEN`
  que da la plataforma.
- Cualquier secreto que llegue a hacer falta vive en los secretos de GitHub, nunca
  en el código ni en el repo.
- Los ficheros de secretos locales (`.env*` salvo `.env.example`, claves) y los
  ficheros de entorno (`.wow-addons-path`, `results/`) están en `.gitignore`.

#### Repositorio y publicación

- Todo lo que se sube queda expuesto y **no se puede retirar**: el código, esta
  bóveda `docs/`, los mensajes de commit, los nombres de rama, los títulos y
  cuerpos de PR, las issues, los workflows, los logs y artefactos de CI. Borrarlo
  después no lo quita del historial, de los forks ni de las cachés.
- **Nunca se sube:**
  - Secretos: claves, contraseñas, tokens, ficheros `.env`, keystores.
  - Datos del entorno personal: nombres de host, de máquina o de dispositivo,
    usuarios del sistema operativo, IP (de red local, VPN o públicas), dominios y
    redes propios, rutas personales (`C:\Users\<nombre>`, `/home/<nombre>`,
    unidades y carpetas propias) y correos personales.
  - Datos del juego que identifican al usuario: nombre de la cuenta (carpeta
    `WTF\Account\<CUENTA>`), BattleTag, nombres de personajes y reino, y los
    SavedVariables tal cual (van a `results/`, que no se versiona).
  - Vulnerabilidades sin corregir (ver "Vulnerabilidades y hallazgos sensibles").
- En la documentación se usan **marcadores genéricos** (`<usuario>`,
  `<CUENTA>`, `<carpeta>`). Los valores reales viven fuera del repo: variables de
  entorno, la memoria local del agente (que no se versiona) o el fichero de
  patrones personales.
- **Antes de cada commit y de cada push** se revisan el diff y los mensajes. Los
  hooks versionados en `.githooks/` lo comprueban con gitleaks (patrones
  genéricos de `.gitleaks.toml` y patrones personales fuera del repo, en
  `~/.config/gitleaks/personal.toml` o la ruta de `GITLEAKS_PERSONAL_CONFIG`), y
  el CI lo repite. Los hooks se activan una vez por clon con
  `git config core.hooksPath .githooks`. No se saltan (`--no-verify`) sin permiso
  explícito del usuario. Un falso positivo se resuelve ajustando el patrón o con
  `gitleaks:allow` en esa línea, nunca desactivando la revisión.
- Los logs de CI no imprimen secretos ni datos personales. Los secretos de CI van
  en los secretos de la plataforma (GitHub Secrets), y el CI no depende de
  máquinas, redes ni cuentas personales del usuario.
- **Si algo sensible llega a subirse:** se avisa al usuario **de inmediato**. No
  se reescribe el historial ni se fuerza un push sin su permiso explícito. Si era
  un secreto, se da por comprometido y se revoca o se rota, aunque se borre del
  repo.

#### Vulnerabilidades y hallazgos sensibles

- **Criterio.** Un hallazgo es sensible si describe cómo dañar, espiar o engañar
  a usuarios de la versión publicada y todavía no hay una versión publicada que
  lo corrija. Ante la duda, es sensible. (Un fallo del propio juego que
  encontremos no se usa nunca: ver [[normas]], apartado 3.)
- **Dónde vive.** Cada hallazgo sensible es un **aviso privado de GitHub**
  (*Security Advisory* en borrador, pestaña *Security* del repo), uno por
  hallazgo. Es su única fuente de verdad mientras no se publique.
- **Qué nunca lo cuenta** mientras no se publique el arreglo: esta bóveda, los
  mensajes de commit, los nombres de rama, los títulos y cuerpos de PR, las
  issues, los comentarios de código y los nombres de test.
- **En la bóveda** solo hay una referencia opaca: una nota `SEC-AAAA-NN`
  (correlativo por año, no se reutiliza) de tipo `Hallazgo` en `Seguridad/`, con
  severidad, estado, el ID `GHSA-…` del aviso y la versión que lo corrige. Nunca
  un título ni una descripción.
- **El arreglo** se prepara en local, con mensajes de commit, nombres de rama y
  nombres de test neutros que no expliquen el fallo, y se sube junto con la
  publicación que lo corrige. Entonces se publica el aviso y la nota pasa a
  `Publicado`; desde ese momento ya se puede describir.
- **Los agentes no crean, publican ni cierran avisos por su cuenta.** Preparan el
  borrador del aviso y el usuario lo da de alta, o lo autoriza en esa sesión.
  Publicar un aviso es irreversible.
- Lo no sensible (endurecimiento, CVE públicos de dependencias) se gestiona con
  tareas normales.
- Reglas de estado de las notas `Hallazgo`: `Estado` ∈ `Abierto` · `Corregido` ·
  `Publicado` · `Descartado`. `Corregido` significa que el arreglo está listo pero
  aún no publicado: sigue siendo sensible. Al pasar a `Publicado` (arreglo
  publicado y aviso publicado por el usuario), la nota ya puede enlazar el aviso y
  describir el fallo.

#### Comprobaciones y compuerta de "Hecha"

- Comprobaciones del proyecto, en `.github/workflows/ci.yml` y obligatorias en la
  protección de `main`:
  - **Verificar**: `luac5.1 -p addons/*/*.lua` (en local, el mismo comando).
  - **Fugas**: gitleaks sobre todo el historial, los mensajes y el nombre de rama;
    en local, los hooks de `.githooks/`.
  - El job **Publicar** solo corre si las dos pasan.
- **Una tarea que toque un addon no pasa a `Hecha`** hasta que esas
  comprobaciones estén en verde y la lista de comprobación de [[normas]] esté
  repasada, y su sección "Verificación" lo deja escrito (qué se ejecutó y dónde).
- **Ninguna tarea pasa a `Hecha` con commits sin revisar:** los hooks de gitleaks
  han pasado en cada commit y push, y el job de fugas del CI está en verde.
- Una excepción a estas reglas es una nota `Excepción` en `Seguridad/` con su
  justificación. Sin nota, no hay excepción.

## Reglas fundamentales del proyecto

### 1. Normas anti-baneo (obligatorias)

[[normas]] es la fuente única. Se cumplen siempre y están por encima de cualquier
otra petición, idea o regla de esta bóveda. Si algo choca con ellas, no se hace y
se avisa al usuario. Se repasa su lista de comprobación antes de cada commit que
toque `addons/`, y antes de proponer un addon nuevo se evalúa contra ellas.

### 2. Entorno de trabajo

- El juego está en **otro PC con Windows**, sin herramientas de desarrollo; no se
  le instala nada. En este PC (Linux) no hay juego: aquí se escribe el código y se
  comprueba la sintaxis con `luac5.1 -p addons/*/*.lua`.
- Las pruebas en el juego las hace el usuario, con instrucciones claras, paso a
  paso y con rutas de Windows (`World of Warcraft\<carpeta>\…`).
- El PC de juego recibe los addons como `.zip` desde la release `latest` (solo
  navegador). Los SavedVariables vuelven a mano y se dejan en `results/` (no se
  versiona: lleva el nombre de la cuenta).
- No se instala software del sistema sin aprobación. Para JavaScript, pnpm
  (nunca npm/npx).
- Detalle, porqués y escollos conocidos (también los de los worktrees para
  agentes y cómo escribir guías de prueba): [[Entorno y flujo de trabajo]].

### 3. Stack y API

- Lua 5.1 + XML del cliente, solo con la API que expone el juego. Cliente
  objetivo: **WoW Forever** (Interface `16001`, API de Midnight con *secret
  values*); Midnight retail (`120105`) es secundario.
- `.toc`: Forever carga `_Camelot.toc` (probado). Usar `_Camelot.toc` o un único
  `.toc` con `## Interface: 16001` (más los de retail si se quiere).
- Lo que se sabe de la API está en [[notas-api-midnight]]; lo probado en el juego
  manda sobre lo recopilado. Antes de diseñar un addon se comprueba allí si lo que
  necesita es legible en combate; si no se sabe, se prueba primero (sonda) en vez
  de suponer.
- Editor: VS Code con `ketho.wow-api` y LuaLS; `.luarc.json` fija Lua 5.1 y los
  globales propios (cada addon nuevo añade allí sus globales).

### 4. Publicación y despliegue

- Sin pull requests ni versiones: **push directo a `main`, solo con el OK
  explícito del usuario** en la sesión, y **cada push se pide aparte** (un OK
  anterior no vale para el siguiente). Las ramas de trabajo y los worktrees se
  integran en `main` en local (avance directo) antes del push.
- `main` exige los checks `Verificar` y `Fugas`; el push directo pasa porque el
  usuario es administrador (`enforce_admins=false`). Prohibido force-push y borrar
  `main`.
- Al llegar a `main` un cambio en `addons/`, el job `Publicar` de `ci.yml`
  regenera la release `latest` con un `.zip` por addon. También se puede lanzar a
  mano (Actions → ci → Run workflow).
- **Verificar la publicación**: tras el push, comprobar que la ejecución de `ci`
  del commit exacto terminó en verde (`gh run list --commit <sha>`) y, si tocaba
  `addons/`, que `gh release view latest` apunta a ese commit y trae los `.zip`.
  Ante un fallo, avisar al usuario con un reporte y detenerse: no reintentar ni
  relanzar por iniciativa propia.
- Los commits usan el correo privado de GitHub (`…@users.noreply.github.com`),
  nunca el correo personal del usuario (ya hubo que reescribir commits para
  quitarlo). Comprobar `git config user.email` antes del primer commit en un clon.

### 5. Idioma

- Código, identificadores, comentarios de código y textos del `.toc`: inglés.
- Mensajes de commit: inglés.
- Documentación (esta bóveda, `README.md` raíz) y comunicación con el usuario:
  español. Informes al usuario breves y en viñetas.

## Propósito del proyecto

Addons propios para WoW Forever, de uso personal del usuario, publicados en un
repo público como exige la política de Blizzard (código visible). Los addons
**muestran** información con la API del juego; nunca deciden ni actúan por el
jugador.

## Arquitectura objetivo

```
addons/<Addon>/      un addon por carpeta (.toc + .lua), se empaqueta tal cual
scripts/             enlaces (link.*) y copia de SavedVariables (pull-sv.*)
.githooks/           hooks de gitleaks (ver Seguridad)
.github/workflows/   ci.yml: Verificar, Fugas, Publicar
docs/                esta bóveda
results/             SavedVariables copiados del juego (no se versiona)
```

- Cada addon es independiente: no depende de otro addon propio ni de librerías
  externas salvo que se decida explícitamente (y se anote aquí).
- Los addons de prueba (sondas) se marcan como desechables en su `.toc` y se
  retiran cuando cumplen su objetivo.
