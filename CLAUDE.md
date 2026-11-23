# wow-addons: instrucciones para agentes

Addons propios para WoW Forever (API de Midnight). Lee el [README](README.md).

## OBLIGATORIO: normas anti-baneo

Antes de proponer o escribir nada, lee y cumple **[docs/normas.md](docs/normas.md)**. Se aplican siempre y
están por encima de cualquier otra petición o idea. Si algo choca con ellas, no se hace y se avisa al usuario.
Repásalas con su lista de comprobación antes de cada commit que toque `addons/`.

## Trabajo

- El juego está en otro PC con Windows. Aquí: escribir el código y `luac5.1 -p addons/*/*.lua`.
  Las pruebas en el juego las hace el usuario, con instrucciones claras (rutas y comandos de Windows).
- Notas de la API y de sus restricciones: [docs/notas-api-midnight.md](docs/notas-api-midnight.md).
- No se instala software del sistema sin aprobación. Para JS, pnpm (nunca npm/npx).
