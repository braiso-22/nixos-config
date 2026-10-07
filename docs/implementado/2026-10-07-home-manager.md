# Fase 1: Home Manager

- **Estado:** implementado
- **Fecha:** 2026-10-07
- **Commit / tag:** ae58bf5 / 0.3.0

## Contexto
Objetivo general: dejar la máquina lista para desarrollo (IDEs, terminal
mejorada, escritorio bspwm). Casi todo eso son dotfiles en `~` (bspwmrc,
sxhkdrc, `.bashrc`, ajustes de VS Code), así que antes de instalar nada se
monta Home Manager para que esa configuración también viva en el repo.
Sin él, habría que escribir esos archivos a mano fuera del repo y migrarlos después.

## Decisiones
- Home Manager **como módulo de NixOS** (no standalone): se aplica con el mismo
  `nixos-rebuild switch`.
- Rama `release-26.05`, a juego con nixpkgs, con `inputs.nixpkgs.follows = "nixpkgs"`
  para no descargar un segundo nixpkgs.
- `useGlobalPkgs` (mismo pkgs y `allowUnfree` que el sistema), `useUserPackages`.
- `backupFileExtension = "hm-backup"`: si ya existe un archivo que Home Manager
  quiere crear, lo renombra en vez de fallar.
- Configuración del usuario en `home.nix`. Desde ahora, las herramientas del
  usuario van ahí; `configuration.nix` queda para lo del sistema.
- git y gh pasan a `home.nix`. `programs.git.enable` se mantiene también a
  nivel de sistema porque lo usa root.
- `programs.gh.gitCredentialHelper`: el `~/.gitconfig` anterior apuntaba a gh
  con una ruta fija de `/nix/store` que se rompería al actualizar gh.

## Resultado
- La configuración de git está en `~/.config/git/config` (generada). El
  `~/.gitconfig` anterior se renombró a `~/.gitconfig.old`.
- La configuración previa de gh quedó en `~/.config/gh/config.yml.hm-backup`;
  la sesión (`hosts.yml`) no se tocó.
- Descarga: 5,6 MiB.
- Se descubrió que existía un tag local `0.2.0` sin subir; se subió y este
  cambio se marcó como `0.3.0`.
