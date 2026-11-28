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
- [ ] Secret scanning activado.
- [ ] Push protection activado (bloquea en el servidor los pushes con secretos
      conocidos).
- [ ] Private vulnerability reporting activado.
- [ ] Protección de `main` con `Verificar` y `Fugas` como obligatorios,
      `enforce_admins=false`, sin force-push ni borrado.
- [ ] Hooks activos en cada clon de trabajo (`git config core.hooksPath`
      apunta a `.githooks`) y gitleaks instalado; fichero de patrones
      personales creado fuera del repo.
- [ ] Alertas de Dependabot activadas (no hay dependencias, pero cubre las
      acciones si algún día se usan).

## Revisiones

| Fecha | Quién | Notas |
| --- | --- | --- |
| 2026-11-28 | agente | Montaje inicial. Revisión del historial con gitleaks: sin fugas (un falso positivo de ejemplo, `/home/yo/`, añadido a las stopwords). |
