# Reorganizar el repo en modules/, hosts/ y users/

- **Estado:** implementado
- **Fecha:** 2026-10-11 (inicio) → 2026-10-11 (fin)
- **Commit / tag:** ver tag 0.10.0

## Contexto
Fase 1 de `flota-equipos.md`. Hoy todo está en archivos sueltos en la raíz
pensados para una sola máquina (`configuration.nix`, `home.nix`...). Para unos
10 portátiles hay que separar lo común, lo de cada máquina y lo de cada
persona. Esta fase **no cambia nada** del sistema: solo mueve código.

## Decisiones
- Estructura:
  ```
  flake.nix                      mkHost: monta cada equipo con sus usuarios
  modules/nixos/                 lo común del sistema (todos los equipos)
    default.nix                  importa el resto y los módulos de los inputs
    sistema.nix                  arranque, red, idioma, teclado, sonido, Nix
    escritorio.nix               X11, LightDM, sesión bspwm, bloqueo
    programas.nix                Firefox, git, Claude, Docker rootless
    home-manager.nix             ajustes globales de Home Manager
    tema.nix                     Stylix
  modules/home/                  lo común del usuario (todas las personas)
    default.nix                  importa el resto
    terminal.nix                 bash, git, gh, starship, fzf, direnv...
    vscode.nix, nuevo-proyecto.nix, escritorio.nix
  hosts/nixos/                   la VM
    default.nix                  hostname, GNOME, invitado QEMU, nix-ld, stateVersion
    hardware-configuration.nix
  users/brais/
    default.nix                  cuenta (NixOS) + engancha su home.nix
    home.nix                     identidad de git, stateVersion, lo propio
  ```
- **Persona y máquina separadas**: `mkHost { host = "..."; users = [ ... ]; }`
  combina un `hosts/<pc>` con varios `users/<persona>`; si alguien cambia de
  portátil solo cambia esa línea.
- Los módulos de los inputs (Home Manager, Stylix, claude-desktop) se importan
  en `modules/nixos/default.nix`; les llegan los inputs con `specialArgs`.
- **La VM sigue llamándose `nixos`** (hostname y `.#nixos`): renombrarla sería
  un cambio funcional y obliga a cambiar el comando de `switch`. Se puede
  hacer más adelante como tarea aparte.
- **GNOME, dconf, invitado QEMU (spice, qemuGuest) y `nix-ld` van al host**:
  son cosas de la VM; los portátiles solo llevan bspwm y no tendrán `nix-ld`.
- `stylix.targets.qt.platform` pasa de `home-manager.users.brais` (en
  `tema.nix`) a `modules/home/escritorio.nix`, para que valga para cualquier
  usuario.
- Se quitan los comentarios de ejemplo que dejó el instalador en
  `configuration.nix` (opciones comentadas que no se usan).
- **Lo común de Home Manager lo importa cada persona** (`imports = [
  ../../modules/home ];` en su `home.nix`) en vez de usar
  `home-manager.sharedModules`: es una línea por persona y se ve de dónde sale
  todo. (Se probó `sharedModules` y funciona igual.)
- **Pendiente para la fase 2** (opciones `empresa.*`): `modules/home/escritorio.nix`
  arranca `spice-vdagent` en la sesión de bspwm, que solo tiene sentido en la
  VM. Se deja como está para no cambiar nada en esta fase.
- **Comprobación**: la derivación del sistema
  (`config.system.build.toplevel.drvPath`) se compara antes y después; si sale
  idéntica, el sistema es el mismo bit a bit (ver Resultado).
  Antes: `3jvl7mr9b08b1w2xsw186nbl7dhcszkf-nixos-system-nixos-26.05.20261006.b253099.drv`.

## Plan
- [x] Crear la estructura y mover el código (`git mv` donde se pueda, para
      conservar el historial)
- [x] `mkHost` en `flake.nix`
- [x] Comprobar que la derivación del sistema es idéntica (ver resultado)
- [x] Aplicar con `switch` y comprobar que todo sigue igual
- [x] Actualizar `CLAUDE.md` y la skill `anadir-paquete` con las rutas nuevas

## Resultado
La derivación del sistema **no** sale idéntica, pero la única diferencia es el
orden de los paquetes en `home-manager-path` (el entorno del usuario): mismas
51 entradas con las mismas prioridades, en otro orden. Todo lo demás que cambia
(`home-manager-files`, `etc`, `activate`...) cambia solo porque depende de él.
El orden no importa: si dos paquetes chocaran en un archivo, `buildEnv`
fallaría en vez de elegir uno. Pasa porque antes `home.nix` definía sus
paquetes y además importaba los otros módulos, y eso no se puede reproducir con
la estructura nueva (se probaron varios órdenes de `imports`).

`dry-build`: 0 MiB de descarga; solo se regeneran en local el entorno del
usuario y los archivos de configuración.

Aplicado con `switch` (23 s, sin descargas): `Done.` sin errores, ningún
servicio fallido, Home Manager aplicado, git con la identidad de siempre y
Docker rootless en marcha.
