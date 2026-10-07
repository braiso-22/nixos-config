# CLAUDE.md, skill anadir-paquete y GitHub CLI

- **Estado:** implementado
- **Fecha:** 2026-10-07
- **Commit / tag:** 2532549, 4dfc56a / —

## Contexto
Dar a Claude Code las instrucciones del repo (cómo trabajar con el usuario,
comandos, trampas) y una forma repetible de añadir paquetes. Instalar `gh`
para trabajar con GitHub.

## Decisiones
- `CLAUDE.md` en español, con las reglas: explicar cada cambio, Claude no usa
  `sudo`, preguntar antes de cada commit, versiones buenas marcadas con tags semver.
- Skill `.claude/skills/anadir-paquete` para el flujo "comprobar nombre →
  añadir → dry-build → aplicar → commit".
- `gh` añadido a `environment.systemPackages` (luego se movió a Home Manager,
  ver `2026-10-07-home-manager.md`).
