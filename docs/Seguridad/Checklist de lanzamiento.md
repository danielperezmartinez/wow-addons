---
Nombre: Checklist de lanzamiento
Tipo: Checklist
Estado: Pendiente
Resumen: Estado de la configuración de GitHub fuera del código (visibilidad, secret scanning, push protection, avisos privados, protección de main, hooks) que ningún test del repo comprueba.
Última revisión: 2026-11-28
Última modificación: 2026-11-28T00:00:00+01:00
---

# Checklist de lanzamiento

Marca cada punto al revisarlo en el panel y anota el valor real. Al terminar,
`Estado: Revisada` y actualiza `Última revisión`. Se revisa al montar, al cambiar
algo de la configuración del repo y, como mínimo, una vez por trimestre.

No hay backend, despliegue web, datos de usuarios ni interfaz web: solo aplica
GitHub.

## GitHub (danielperezmartinez/wow-addons)

- [x] Visibilidad del repo: **público** (2026-11-28), coherente con las reglas de
      "Repositorio y publicación" y con la política de Blizzard (código visible).
- [x] Secret scanning activado (2026-11-28).
- [x] Push protection activado (bloquea en el servidor los pushes con secretos
      conocidos) (2026-11-28).
- [ ] Private vulnerability reporting activado. **Desactivado** a 2026-11-28;
      lo activa el usuario en Settings → Security si quiere.
- [x] Protección de `main` con `Verificar` y `Fugas` como obligatorios
      (`strict=false`), `enforce_admins=false`, sin force-push ni borrado
      (aplicada el 2026-11-28).
- [x] Hooks activos en el clon del PC de desarrollo (`core.hooksPath` =
      `.githooks`), gitleaks instalado y fichero de patrones personales fuera
      del repo (2026-11-28). Repetir en cualquier clon nuevo.
- [ ] Alertas de Dependabot activadas (no hay dependencias, pero cubre las
      acciones si algún día se usan).

## Revisiones

| Fecha | Quién | Notas |
| --- | --- | --- |
| 2026-11-28 | agente | Montaje inicial. Revisión del historial con gitleaks: sin fugas (un falso positivo de ejemplo, `/home/yo/`, añadido a las stopwords). Protección de `main` aplicada; secret scanning y push protection ya activos; falta private vulnerability reporting y Dependabot. |
