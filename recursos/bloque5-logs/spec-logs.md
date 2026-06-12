# Spec: la skill aprende a leer logs (Bloque 5)

> **Tool-agnostic:** este texto se pega en `/speckit.specify` (Camino A) o al
> crear el Feature Spec en Kiro (Camino B). Es una **evolución de la spec** de
> `issues-ops` — el punto fuerte de SDD: cambia el requisito, cambia la spec,
> se regenera la skill. Requiere la carpeta `recursos/bloque5-logs/logs/` (3 archivos).

---

Quiero **extender la Skill `issues-ops`** con una capacidad nueva: **análisis
forense de logs distribuidos**. El input no es un archivo: es una **carpeta**
con los logs de distintas capas del sistema (p. ej. `gateway.log` con los
accesos/errores del API gateway, `services.log` con los logs de aplicación de
los microservicios, `infra.log` con eventos de infraestructura: cron, deploys,
métricas de hosts, NTP, backups).

**El supuesto clave:** los problemas reales rara vez se ven en un solo archivo.
El ERROR de una capa suele ser el **síntoma**; la **causa raíz** suele ser una
línea INFO inocente en otra capa, minutos u horas antes. La skill debe razonar
**entre archivos**, no greppear dentro de uno.

## Procedimiento de análisis

1. **Inventariar** los archivos de la carpeta y entender qué capa describe cada
   uno (formato: timestamp ISO + nivel + servicio/componente + mensaje).
2. **Separar síntomas de ruido**: errores que se auto-resuelven (retries que
   terminan OK), issues ya conocidos marcados en el propio log, y chatter
   operativo normal **no son hallazgos** — pero hay que descartarlos
   explícitamente, con justificación.
3. **Detectar anomalías aunque no haya ERROR**, incluyendo:
   - **Periodicidad**: síntomas que se repiten en ventanas regulares (cada
     hora, cada noche) — buscar qué evento de otra capa coincide con el inicio
     de cada ventana.
   - **Tendencias**: métricas dentro de líneas INFO que crecen o degradan
     gradualmente (pools, heap, disco) — identificar el evento que inició la
     tendencia, aunque esté horas antes.
   - **Ventanas acotadas**: ráfagas de errores que empiezan y terminan de
     golpe — buscar el evento puntual que abre la ventana.
4. **Construir la cadena causal completa** de cada hallazgo: evento origen (con
   archivo y timestamp) → efecto intermedio → síntoma visible. Citar 1-2 líneas
   representativas de **cada archivo** involucrado.
5. **Comparar contra los issues existentes** con `issues-api:list_issues`:
   - Si el hallazgo explica un issue ya registrado → `issues-api:update_issue`
     sumando la causa raíz y la evidencia a `description` (sin borrar lo
     original) y mejorando `proposed_solution` con un fix dirigido a la causa,
     no al síntoma.
   - Si es un problema nuevo → `issues-api:add_issue` con severity acorde al
     impacto y una solución propuesta concreta.
6. **Nunca crear duplicados**: ante la duda, consultar con
   `issues-api:get_issue`; si sigue ambiguo, preguntar al usuario.
7. **Cerrar con un informe**: tabla de hallazgos (causa raíz → síntoma →
   issue actualizado/creado) y lista de descartados con el porqué.

## Reglas que se mantienen

Todas las reglas de `issues-ops` siguen vigentes (nombres calificados, enums
válidos, `resolved` exige solución, confirmar leyendo el issue).

## Criterios de aceptación

- Con la carpeta `recursos/bloque5-logs/logs/` provista, el análisis identifica **al menos
  3 cadenas causales que cruzan 2 o más archivos** (evento en una capa →
  síntoma en otra).
- Detecta al menos **una periodicidad** (síntoma recurrente en ventanas
  regulares) y **una tendencia** (métrica que degrada gradualmente tras un
  evento puntual), nombrando el evento origen de cada una.
- **Actualiza** los issues existentes que los hallazgos explican (sin
  duplicar) y **crea** los genuinamente nuevos.
- **Descarta explícitamente** los errores ruidosos que no son problema (los
  que se auto-resuelven o están marcados como conocidos), con justificación.
- El informe final cita líneas de log concretas (timestamp + archivo) como
  evidencia de cada cadena causal.

Ubicación del artefacto: el mismo `SKILL.md` de `issues-ops` (se actualiza, no
se crea una skill nueva).
