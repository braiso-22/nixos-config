# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es este repo

Configuración de NixOS de una única máquina: una VM QEMU **aarch64** (UTM en un Mac, sin aceleración gráfica) con escritorio **bspwm** (X11) y GNOME de reserva (hostname `test-nixos-vm`, usuario `brais`). `/etc/nixos` es un enlace simbólico a este repo, así que lo que hay aquí *es* la configuración del sistema; los archivos se editan sin `sudo`.

## Cómo trabajar con el usuario

- El usuario es principiante en NixOS. Responde **en español** y explica brevemente qué hace cada cambio y cada comando.
- Tú no puedes usar `sudo` (pide contraseña). Tras un cambio: valida tú sin `sudo` y dale al usuario el comando para aplicarlo; luego lee su terminal para comprobar el resultado.
- **Pregunta siempre antes de hacer commit**, proponiendo el mensaje (en español). Las versiones que le gustan se marcan con tags de git semver (`0.1.0`, …).
- **Documenta cada tarea en `docs/` antes de empezarla** (ver `docs/README.md`): crea o actualiza `docs/todo/<tarea>.md` con contexto, decisiones (y por qué) y plan; ve anotando decisiones nuevas; al terminar, `git mv` a `docs/implementado/AAAA-MM-DD-<tarea>.md`, rellena el resultado (commit, tag, tamaño de descarga, problemas) y mételo en el mismo commit. Ideas sin decidir: `docs/todo/ideas.md`. Al empezar una sesión, mira `docs/todo/` para saber qué hay pendiente.

## Comandos

```bash
nixos-rebuild dry-build --flake .#test-nixos-vm    # validar sin sudo (evalúa y dice qué se descargaría/compilaría)
sudo nixos-rebuild switch --flake ~/nixos-config   # aplicar (lo ejecuta el usuario; sin #nombre usa el hostname; alias: rebuild)
nix eval --raw .#nixosConfigurations.test-nixos-vm.pkgs.<attr>.meta.description   # comprobar que un paquete existe en el nixpkgs fijado
nix eval .#nixosConfigurations.test-nixos-vm.options.programs --apply 'builtins.hasAttr "<nombre>"'   # ¿tiene módulo programs.<nombre>?
nix eval .#nixosConfigurations.test-nixos-vm.config.home-manager.users.brais.programs --apply 'p: builtins.hasAttr "<nombre>" p'   # ¿tiene módulo programs.<nombre> en Home Manager?
nix flake update nixpkgs                           # actualizar nixpkgs dentro de nixos-26.05 (cambia flake.lock)
nixfmt <archivo>.nix                                # formatear (estilo oficial de Nix)
```

`dry-build` imprime `these N paths will be fetched (X MiB download…)`: menciona ese tamaño al usuario antes de que aplique, le importa no descargar gigas.

## Arquitectura

Preparado para varios equipos (fase 1 de `docs/todo/flota-equipos.md`): lo común, lo de cada máquina y lo de cada persona van separados. Hoy solo hay un equipo, la VM de pruebas (`test-nixos-vm`).

- `flake.nix`: cuatro inputs: `nixpkgs` (rama estable **nixos-26.05**; el usuario rechazó unstable expresamente), `claude-desktop` (flake de terceros `github:poeck/claude-desktop-nix-flake`, cuyo módulo se activa con `programs.claude-desktop.enable`), `home-manager` (rama `release-26.05`, con `follows` al nixpkgs del sistema), cargado como módulo de NixOS, y `stylix` (rama `release-26.05`, `follows`), tema común. El input de claude-desktop trae su propio nixpkgs-unstable en `flake.lock` (`nixpkgs`), distinto del del sistema (`nixpkgs_2`).
  - `mkHost { host = "<pc>"; users = [ "<persona>" ... ]; }` monta cada `nixosConfigurations.<pc>` con `modules/nixos` + `hosts/<pc>` + `users/<persona>`. Los módulos reciben los inputs con `specialArgs` (`{ inputs, ... }`).
  - No hay `system =`: la arquitectura sale de `nixpkgs.hostPlatform` en el `hardware-configuration.nix` de cada host.
- `modules/nixos/`: lo **común del sistema**. `default.nix` importa el resto y los módulos de los inputs; `sistema.nix` (arranque, red, idioma, sonido, Nix y su limpieza), `escritorio.nix` (X11, LightDM, sesión bspwm, bloqueo, teclado, scroll), `programas.nix` (Firefox, git, Claude, Docker rootless), `vm.nix` y `gnome.nix` (opciones `empresa.*`, abajo), `home-manager.nix` (ajustes globales de HM) y `tema.nix` (Stylix con Catppuccin Mocha, fuentes, cursor y fondo; se aplica también en Home Manager; objetivos `gnome`, `gtksourceview` y `nixos-icons` desactivados: recompilan GNOME sin caché, ~1 GiB y mucha compilación).
- **Opciones `empresa.*`** (fase 2): lo que llevan solo algunos equipos. Cada opción se declara en el mismo archivo de `modules/nixos/` que la implementa (`options.empresa.<x>.enable = lib.mkEnableOption ...;` + `config = lib.mkIf config.empresa.<x>.enable { ... };`), desactivada por defecto, y el host la activa (`empresa.vm.enable = true;`). Si necesita algo de Home Manager para todos los usuarios, lo añade con `home-manager.sharedModules`. Hoy: `empresa.vm` (invitado QEMU/UTM: spice, qemuGuest, `spice-vdagent` en la sesión bspwm) y `empresa.gnome` (GNOME de reserva y su dconf).
- `modules/home/`: lo **común del usuario** (Home Manager). `terminal.nix` (bash, git, gh, starship, fzf, direnv...), `vscode.nix` (un perfil por lenguaje: default, typescript, csharp), `nuevo-proyecto.nix` (comando del mismo nombre) y `escritorio.nix` (bspwm, sxhkd, polybar, rofi, picom, dunst, alacritty, flameshot, bloqueo). Los atajos están en la lista `atajos` de `escritorio.nix`, de la que salen sxhkd y la chuleta (Cmd+I). Se aplica con el mismo `nixos-rebuild switch`.
- `hosts/<pc>/`: lo de **cada máquina**. `default.nix` (hostname, `system.stateVersion` y lo propio) + `hardware-configuration.nix`. En `hosts/test-nixos-vm`: activa `empresa.vm` y `empresa.gnome`, y `nix-ld`.
- `users/<persona>/`: lo de **cada persona**. `default.nix` (cuenta `users.users.<persona>` y `home-manager.users.<persona> = import ./home.nix`) y `home.nix` (importa `../../modules/home`; identidad de git, `home.stateVersion` y sus programas propios).
- Dónde va algo nuevo: herramientas de usuario → `modules/home` si es para todos, `users/<persona>/home.nix` si es solo de esa persona; servicios y cosas con root → `modules/nixos`, o `hosts/<pc>` si es solo de esa máquina.
- `templates/<lenguaje>/` (kotlin, typescript, csharp): plantillas de entorno por proyecto (`devShell` + `.envrc` para direnv), expuestas como salida `templates` de `flake.nix`. **No cambian el sistema** (no hace falta `switch` para editarlas). Se usan con `nuevo-proyecto <lenguaje>`, que fija el nixpkgs de cada proyecto a la revisión del sistema para reutilizar lo instalado. Los lenguajes (JDK, Node, .NET) no se instalan en el sistema.
- En ambos, si un programa tiene módulo `programs.<nombre>`, se prefiere a añadir el paquete suelto (`home.packages` o `environment.systemPackages`): el módulo configura también la integración (bash, git…).
- Los `.nix` siguen el estilo de **nixfmt**: después de editar uno, pásale `nixfmt` (VS Code lo hace al guardar con Ctrl+S). Excepto `hardware-configuration.nix`.
- `hardware-configuration.nix` lo genera `nixos-generate-config`: no lo edites.
- `system.stateVersion` y `home.stateVersion` (`"26.05"`) no se cambian nunca, ni al actualizar.
- Para comprobar que una reorganización no cambia nada: comparar `nix eval --raw .#nixosConfigurations.test-nixos-vm.config.system.build.toplevel.drvPath` antes y después. Ojo: mover definiciones entre archivos puede cambiar el orden de las listas (p. ej. paquetes de `home-manager-path`) y con ello el hash, sin cambio funcional.

## Trampas

- **Escritorio**: la sesión `bspwm` de LightDM ejecuta `~/.hm-xsession`; los servicios solo de bspwm (picom, flameshot, bloqueo) se atan a `hm-graphical-session.target`, no a `graphical-session.target` (si no, arrancan también en GNOME). Cambiar LightDM con `switch` no cierra la sesión (`display-manager` tiene `restartIfChanged = false`); se nota al volver a entrar. En comandos de sxhkd las llaves `{}` son sintaxis propia: si un comando las necesita, va en un `writeShellScript`. Los paquetes pueden traer autoarranques XDG (`etc/xdg/autostart`) que Home Manager ejecuta en la sesión: ocultarlos con `xdg.configFile."autostart/X.desktop"` y `Hidden=true`. En el Mac, macOS se queda Cmd+Q/H/W/M/Tab/Espacio si UTM no captura el teclado.
- Con flakes, Nix **solo ve archivos añadidos a git**: un archivo nuevo necesita `git add` antes de `dry-build`/`switch`, o dará "does not exist".
- **Disco justo (48 GB, ampliado desde 41; el Mac no tiene más espacio)**: hay limpieza automática semanal (`nix.gc`, generaciones de más de 14 días, y `nix.optimise`), pero compilar paquetes no libres grandes llega a ~19 GB de pico (pasó con IntelliJ, ya quitado). Si el `switch` falla con "No space left on device": borrar generaciones viejas (`sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system`) y `sudo nix-collect-garbage`. `dry-build` no cuenta lo que se descarga de fuera de la caché (VS Code, extensiones): estímalo aparte.
- Archivos creados por el usuario con `sudo` quedan como `root` y no podrás editarlos; pídele `sudo chown brais:users <archivo>`.
- Copia de seguridad de la `/etc/nixos` original (pre-flake, con channels) en `/etc/nixos.bak`.
