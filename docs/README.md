# Documentación de tareas

Cada tarea (por pequeña que sea) tiene un archivo `.md` con su contexto, las
decisiones que se tomaron y por qué. Así cualquier día se puede retomar una
tarea pendiente o entender por qué la configuración es como es.

```
docs/
├── todo/          tareas pendientes o en curso
└── implementado/  tareas terminadas (con fecha, commit y tag)
```

## Flujo

1. **Antes de empezar** una tarea se crea (o se actualiza, si ya existía)
   su archivo en `todo/` con el contexto y las decisiones. Nombre sin fecha:
   `todo/escritorio-bspwm.md`.
2. Mientras se trabaja, se anotan las decisiones nuevas o los cambios de plan.
3. **Al terminar**, se mueve a `implementado/` con la fecha delante
   (`git mv todo/escritorio-bspwm.md implementado/2026-10-08-escritorio-bspwm.md`),
   se rellena el resultado y se incluye en el mismo commit que el cambio.

Las ideas sueltas que aún no son una tarea van en `todo/ideas.md`.

## Plantilla

```markdown
# Título de la tarea

- **Estado:** pendiente | en curso | implementado
- **Fecha:** 2026-10-07 (inicio) → 2026-10-08 (fin)
- **Commit / tag:** abc1234 / 0.4.0

## Contexto
Qué se quiere conseguir y por qué. Situación de partida.

## Decisiones
- Qué se eligió **y por qué** (y qué alternativas se descartaron).

## Plan
- [ ] Paso 1
- [ ] Paso 2

## Resultado
Qué quedó hecho, cómo se usa, problemas encontrados y cómo se resolvieron.
```
