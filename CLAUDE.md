# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es este repo

Configuración de NixOS de una única máquina: una VM QEMU **aarch64** con GNOME (hostname `nixos`, usuario `brais`). `/etc/nixos` es un enlace simbólico a este repo, así que lo que hay aquí *es* la configuración del sistema; los archivos se editan sin `sudo`.

## Cómo trabajar con el usuario

- El usuario es principiante en NixOS. Responde **en español** y explica brevemente qué hace cada cambio y cada comando.
- Tú no puedes usar `sudo` (pide contraseña). Tras un cambio: valida tú sin `sudo` y dale al usuario el comando para aplicarlo; luego lee su terminal para comprobar el resultado.
- **Pregunta siempre antes de hacer commit**, proponiendo el mensaje (en español). Las versiones que le gustan se marcan con tags de git semver (`0.1.0`, …).

## Comandos

```bash
nixos-rebuild dry-build --flake .#nixos            # validar sin sudo (evalúa y dice qué se descargaría/compilaría)
sudo nixos-rebuild switch --flake ~/nixos-config#nixos   # aplicar (lo ejecuta el usuario)
nix eval --raw .#nixosConfigurations.nixos.pkgs.<attr>.meta.description   # comprobar que un paquete existe en el nixpkgs fijado
nix eval .#nixosConfigurations.nixos.options.programs --apply 'builtins.hasAttr "<nombre>"'   # ¿tiene módulo programs.<nombre>?
nix flake update nixpkgs                           # actualizar nixpkgs dentro de nixos-26.05 (cambia flake.lock)
```

`dry-build` imprime `these N paths will be fetched (X MiB download…)`: menciona ese tamaño al usuario antes de que aplique, le importa no descargar gigas.

## Arquitectura

- `flake.nix` define `nixosConfigurations.nixos` con dos inputs: `nixpkgs` (rama estable **nixos-26.05**; el usuario rechazó unstable expresamente) y `claude-desktop` (flake de terceros `github:poeck/claude-desktop-nix-flake`, cuyo módulo se activa con `programs.claude-desktop.enable`). Ese input trae su propio nixpkgs-unstable en `flake.lock` (`nixpkgs`), distinto del del sistema (`nixpkgs_2`).
- No hay `system =` en `nixosSystem`: la arquitectura sale de `nixpkgs.hostPlatform` en `hardware-configuration.nix`.
- `configuration.nix` es un único archivo con toda la configuración. Si un programa tiene módulo `programs.<nombre>.enable` (como `git` o `firefox`), se prefiere eso a añadir el paquete a `environment.systemPackages`.
- `hardware-configuration.nix` lo genera `nixos-generate-config`: no lo edites.
- `system.stateVersion = "26.05"` no se cambia nunca, ni al actualizar.

## Trampas

- Con flakes, Nix **solo ve archivos añadidos a git**: un archivo nuevo necesita `git add` antes de `dry-build`/`switch`, o dará "does not exist".
- Archivos creados por el usuario con `sudo` quedan como `root` y no podrás editarlos; pídele `sudo chown brais:users <archivo>`.
- Copia de seguridad de la `/etc/nixos` original (pre-flake, con channels) en `/etc/nixos.bak`.
