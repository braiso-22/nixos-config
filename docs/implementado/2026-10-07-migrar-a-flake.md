# Migrar a flake y añadir Claude Desktop

- **Estado:** implementado
- **Fecha:** 2026-10-07
- **Commit / tag:** a3b44c2 / 0.1.0

## Contexto
Pasar de channels a un flake para tener versiones fijadas (`flake.lock`) y
poder usar flakes de terceros, como el de Claude Desktop.

## Decisiones
- **nixpkgs estable `nixos-26.05`**, no unstable: se prefiere estabilidad
  (unstable se descartó expresamente).
- Claude Desktop desde el flake de terceros `github:poeck/claude-desktop-nix-flake`,
  activado con `programs.claude-desktop.enable`. Ese flake trae su propio
  nixpkgs-unstable en `flake.lock`.
- `/etc/nixos` pasa a ser un enlace simbólico a `~/nixos-config`, para editar
  sin `sudo`.
- Se activan los servicios de invitado de la VM: `services.qemuGuest` y
  `services.spice-vdagentd` (portapapeles y resolución automática), y
  `programs.nix-ld` (permite ejecutar binarios no compilados para NixOS).

## Resultado
Se aplica con `sudo nixos-rebuild switch --flake ~/nixos-config#nixos`.
