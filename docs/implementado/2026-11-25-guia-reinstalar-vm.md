# Guía para reinstalar la VM

- **Estado:** implementado
- **Fecha:** 2026-11-25
- **Commit / tag:** ver `git log` / —

## Contexto
El usuario quiere borrar la VM para liberar espacio en el Mac. La configuración
está en GitHub, pero no había ningún sitio que explicara cómo recrear la VM.

## Decisiones
- Guía suelta en `docs/reinstalar-vm.md` (no es una tarea, es un "cómo se hace").
- Instalación con el instalador gráfico de NixOS y después `switch` al flake, no
  `nixos-install --flake` desde la ISO mínima: más sencillo y es lo que se hizo
  la primera vez.
- Lo que solo estaba en la memoria local de Claude (reiniciar tras cambios de
  teclado o scroll) pasa a `CLAUDE.md`, porque la memoria se pierde con la VM.

## Resultado
Guía con los pasos de UTM, el instalador, el primer `switch` (con
`hardware-configuration.nix` nuevo y flakes activados con `NIX_CONFIG`) y los
remates. Sin probar todavía: se probará al recrear la VM.
