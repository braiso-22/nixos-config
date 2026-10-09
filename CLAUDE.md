# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es este repo

Configuración de NixOS de una única máquina: una VM QEMU **aarch64** con GNOME (hostname `nixos`, usuario `brais`). `/etc/nixos` es un enlace simbólico a este repo, así que lo que hay aquí *es* la configuración del sistema; los archivos se editan sin `sudo`.

## Cómo trabajar con el usuario

- El usuario es principiante en NixOS. Responde **en español** y explica brevemente qué hace cada cambio y cada comando.
- Tú no puedes usar `sudo` (pide contraseña). Tras un cambio: valida tú sin `sudo` y dale al usuario el comando para aplicarlo; luego lee su terminal para comprobar el resultado.
- **Pregunta siempre antes de hacer commit**, proponiendo el mensaje (en español). Las versiones que le gustan se marcan con tags de git semver (`0.1.0`, …).
- **Documenta cada tarea en `docs/` antes de empezarla** (ver `docs/README.md`): crea o actualiza `docs/todo/<tarea>.md` con contexto, decisiones (y por qué) y plan; ve anotando decisiones nuevas; al terminar, `git mv` a `docs/implementado/AAAA-MM-DD-<tarea>.md`, rellena el resultado (commit, tag, tamaño de descarga, problemas) y mételo en el mismo commit. Ideas sin decidir: `docs/todo/ideas.md`. Al empezar una sesión, mira `docs/todo/` para saber qué hay pendiente.

## Comandos

```bash
nixos-rebuild dry-build --flake .#nixos            # validar sin sudo (evalúa y dice qué se descargaría/compilaría)
sudo nixos-rebuild switch --flake ~/nixos-config#nixos   # aplicar (lo ejecuta el usuario)
nix eval --raw .#nixosConfigurations.nixos.pkgs.<attr>.meta.description   # comprobar que un paquete existe en el nixpkgs fijado
nix eval .#nixosConfigurations.nixos.options.programs --apply 'builtins.hasAttr "<nombre>"'   # ¿tiene módulo programs.<nombre>?
nix eval .#nixosConfigurations.nixos.config.home-manager.users.brais.programs --apply 'p: builtins.hasAttr "<nombre>" p'   # ¿tiene módulo programs.<nombre> en Home Manager?
nix flake update nixpkgs                           # actualizar nixpkgs dentro de nixos-26.05 (cambia flake.lock)
nixfmt <archivo>.nix                                # formatear (estilo oficial de Nix)
```

`dry-build` imprime `these N paths will be fetched (X MiB download…)`: menciona ese tamaño al usuario antes de que aplique, le importa no descargar gigas.

## Arquitectura

- `flake.nix` define `nixosConfigurations.nixos` con tres inputs: `nixpkgs` (rama estable **nixos-26.05**; el usuario rechazó unstable expresamente), `claude-desktop` (flake de terceros `github:poeck/claude-desktop-nix-flake`, cuyo módulo se activa con `programs.claude-desktop.enable`); y `home-manager` (rama `release-26.05`, con `follows` al nixpkgs del sistema), cargado como módulo de NixOS. El input de claude-desktop trae su propio nixpkgs-unstable en `flake.lock` (`nixpkgs`), distinto del del sistema (`nixpkgs_2`).
- No hay `system =` en `nixosSystem`: la arquitectura sale de `nixpkgs.hostPlatform` en `hardware-configuration.nix`.
- `configuration.nix`: lo del **sistema** (arranque, servicios, escritorio, usuarios).
- `home.nix`: lo del **usuario** con Home Manager (herramientas de terminal, IDEs, dotfiles). Se aplica con el mismo `nixos-rebuild switch`. Las herramientas del usuario van aquí.
  - Importa módulos propios: `vscode.nix` (VS Code con un perfil por lenguaje: default, typescript, csharp), `jetbrains.nix` (IntelliJ IDEA de nixpkgs) y `nuevo-proyecto.nix` (comando del mismo nombre).
- `templates/<lenguaje>/` (kotlin, typescript, csharp): plantillas de entorno por proyecto (`devShell` + `.envrc` para direnv), expuestas como salida `templates` de `flake.nix`. **No cambian el sistema** (no hace falta `switch` para editarlas). Se usan con `nuevo-proyecto <lenguaje>`, que fija el nixpkgs de cada proyecto a la revisión del sistema para reutilizar lo instalado. Los lenguajes (JDK, Node, .NET) no se instalan en el sistema.
- En ambos, si un programa tiene módulo `programs.<nombre>`, se prefiere a añadir el paquete suelto (`home.packages` o `environment.systemPackages`): el módulo configura también la integración (bash, git…).
- Los `.nix` siguen el estilo de **nixfmt**: después de editar uno, pásale `nixfmt` (VS Code lo hace al guardar con Ctrl+S). Excepto `hardware-configuration.nix`.
- `hardware-configuration.nix` lo genera `nixos-generate-config`: no lo edites.
- `system.stateVersion = "26.05"` no se cambia nunca, ni al actualizar.

## Trampas

- Con flakes, Nix **solo ve archivos añadidos a git**: un archivo nuevo necesita `git add` antes de `dry-build`/`switch`, o dará "does not exist".
- **Disco justo (48 GB, ampliado desde 41; el Mac no tiene más espacio)**: hay limpieza automática semanal (`nix.gc`, generaciones de más de 14 días, y `nix.optimise`), pero compilar paquetes no libres grandes (IntelliJ) llega a ~19 GB de pico. Si el `switch` falla con "No space left on device": borrar generaciones viejas (`sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system`) y `sudo nix-collect-garbage`. `dry-build` no cuenta lo que se descarga de fuera de la caché (VS Code, IntelliJ, extensiones): estímalo aparte.
- Archivos creados por el usuario con `sudo` quedan como `root` y no podrás editarlos; pídele `sudo chown brais:users <archivo>`.
- Copia de seguridad de la `/etc/nixos` original (pre-flake, con channels) en `/etc/nixos.bak`.
