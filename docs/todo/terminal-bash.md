# Fase 2: bash mejorada y herramientas de terminal

- **Estado:** en curso (configurada y validada con dry-build, falta aplicar)
- **Fecha:** 2026-10-07
- **Commit / tag:** — / 0.4.0 (previsto)

## Contexto
Tener una terminal productiva para desarrollo: prompt informativo, búsqueda
rápida en historial y archivos, navegación rápida entre carpetas, y la base
(direnv) para los entornos por proyecto de la fase 3.

## Decisiones
- Todo en `home.nix` con módulos `programs.<x>` de Home Manager (configuran
  también la integración con bash), no como paquetes sueltos.
- **bash** se mantiene como shell (no zsh/fish), mejorada: historial de 100 000
  líneas sin duplicados, `histappend`, `globstar`, `autocd`, `cdspell`, alias
  `..`, `lg`, `rebuild`.
- **starship** como prompt, con la configuración por defecto (el tema se
  unificará en la fase 4 con Stylix).
- **eza** con iconos y git (crea los alias ls/ll/la/lt). **bat**, **ripgrep**,
  **fd**, **jq**, **btop**.
- **fzf** para el historial (Ctrl+R) en vez de atuin: más simple, sin base de
  datos ni sincronización. Usa `fd` para buscar (incluye ocultos, excluye `.git`).
- **zoxide** con el comando `z` (no reemplaza a `cd`, para no confundir).
- **direnv + nix-direnv**: entornos por proyecto con `use flake`.
- **lazygit** + **delta** (diffs de git con colores).
- **tealdeer** (`tldr`) con autoactualización.
- Fuente **JetBrainsMono Nerd Font** (hace falta para los iconos), puesta como
  fuente monoespaciada de GNOME vía dconf, porque GNOME Console (kgx) usa esa.
  Es lo que más pesa de la descarga (~220 MiB instalada).

## Plan
- [x] Configurar en `home.nix`
- [x] `dry-build`: 153 MiB de descarga
- [ ] Aplicar con `sudo nixos-rebuild switch` y abrir una terminal nueva
- [ ] Comprobar prompt, iconos, Ctrl+R, `z`, `lg`
- [ ] Commit + tag `0.4.0`, mover este archivo a `implementado/`

## Resultado
