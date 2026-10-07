# Instalación base de NixOS

- **Estado:** implementado
- **Fecha:** 2026-10-06
- **Commit / tag:** c4ca26a / —

## Contexto
Instalación inicial de NixOS en una VM QEMU aarch64 sobre un MacBook Pro, para
tener una máquina de desarrollo configurada de forma declarativa.

## Decisiones
- Configuración generada por el instalador, con GNOME como escritorio (GDM).
- Idioma `es_ES.UTF-8`, zona horaria `Europe/Madrid`, teclado `es`.
- Sonido con PipeWire.

## Resultado
`configuration.nix` y `hardware-configuration.nix` versionados en git. En ese
momento se usaban channels; la `/etc/nixos` original se guardó en `/etc/nixos.bak`.
