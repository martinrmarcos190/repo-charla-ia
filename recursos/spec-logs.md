# Spec: la skill aprende a leer logs (Bloque 5)

> **Tool-agnostic:** este texto se pega en `/speckit.specify` (Camino A) o al
> crear el Feature Spec en Kiro (Camino B). Es una **evolución de la spec** de
> `issues-ops` — el punto fuerte de SDD: cambia el requisito, cambia la spec,
> se regenera la skill. Requiere el archivo `recursos/logs/app.log`.

---

Quiero **extender la Skill `issues-ops`** con una capacidad nueva: **análisis de
logs**. Cuando el usuario pida analizar un archivo de logs (le va a pasar la
ruta), la skill debe:

## Procedimiento de análisis

1. **Leer el archivo de logs** completo (formato: una línea por evento, con
   timestamp ISO, nivel `INFO/WARN/ERROR/FATAL`, servicio y mensaje).
2. **Ignorar el ruido**: las líneas INFO de requests normales, health checks y
   cache no son issues.
3. **Agrupar los problemas por patrón**: mismo servicio + mismo tipo de error =
   un solo problema, con su frecuencia (cantidad de ocurrencias) y ventana
   temporal (primera y última aparición).
4. **Comparar contra los issues existentes** usando `issues-api:list_issues`:
   - Si el patrón corresponde a un issue ya registrado (mismo servicio y
     síntoma): **actualizarlo** con `issues-api:update_issue`, sumando la
     evidencia a `description` (frecuencia, ventana temporal, 1-2 líneas de log
     representativas) — sin borrar la descripción original.
   - Si es un problema nuevo: **crearlo** con `issues-api:add_issue`, con
     `severity` propuesta según frecuencia y criticidad (un FATAL recurrente o
     un recurso al 97% es `critical`; warnings preventivos son `medium`/`low`)
     y una `proposed_solution` concreta.
5. **Correlacionar señales entre servicios**: si dos patrones parecen
   relacionados (p. ej. el disco de una DB llenándose y los backups de esa DB
   fallando), decirlo explícitamente y sumar la hipótesis de causa raíz a la
   descripción del issue correspondiente.
6. **Nunca crear duplicados**: ante la duda entre actualizar y crear, consultar
   el issue existente con `issues-api:get_issue` y decidir; si sigue ambiguo,
   preguntar al usuario.
7. **Cerrar con un resumen**: tabla legible de qué issues se crearon, cuáles se
   actualizaron y qué quedó descartado como ruido.

## Reglas que se mantienen

Todas las reglas de `issues-ops` siguen vigentes (nombres calificados, enums
válidos, `resolved` exige solución, confirmar leyendo el issue).

## Criterios de aceptación

- Con el `app.log` provisto, el análisis detecta **al menos 4 patrones de
  problema** distintos entre el ruido.
- Al menos **un issue existente se actualiza** con evidencia (no se duplica).
- Al menos **un issue nuevo se crea** con severity y solución propuesta.
- La correlación disco↔backups (o equivalente) aparece mencionada.
- El resumen final lista creados / actualizados / descartados.

Ubicación del artefacto: el mismo `SKILL.md` de `issues-ops` (se actualiza, no
se crea una skill nueva).
