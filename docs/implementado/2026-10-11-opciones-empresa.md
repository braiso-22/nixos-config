# Opciones propias empresa.*

- **Estado:** implementado
- **Fecha:** 2026-10-11 (inicio) → 2026-10-11 (fin)
- **Commit / tag:** ver tag 0.11.0

## Contexto
Fase 2 de `flota-equipos.md`. Tras la fase 1, `modules/` tiene lo común y
`hosts/<pc>` lo de cada máquina, pero hay cosas que no son de todos ni de una
sola máquina: lo de "ser una VM" o "tener GNOME de reserva". Además, el
escritorio común arranca `spice-vdagent` (portapapeles con el Mac), que solo
sirve en la VM. Con opciones propias (`empresa.<algo>.enable`) cada host activa
lo que necesita con una línea, y el código vive en un único sitio.

## Decisiones
- Cada opción se declara **en el mismo archivo que la implementa**
  (`options.empresa.X` + `config = lib.mkIf ...`): así se ve de un vistazo qué
  hace cada una. Van en `modules/nixos/`.
- Opciones de esta fase:
  - `empresa.vm.enable` (`modules/nixos/vm.nix`): invitado de QEMU/UTM:
    `spice-vdagentd`, `qemuGuest` y `spice-vdagent` en la sesión de bspwm (esto
    último es de Home Manager: se añade con `home-manager.sharedModules`, para
    que todo lo de la VM esté en un archivo).
  - `empresa.gnome.enable` (`modules/nixos/gnome.nix`): GNOME como sesión de
    reserva y sus ajustes dconf.
  - Las dos están desactivadas por defecto; el host de la VM las activa.
- Prefijo `empresa.` (ya decidido en el plan): distingue lo nuestro de las
  opciones de NixOS.
- `nix-ld` se queda en el host: en la fase de bloqueo se quitará.
- Las opciones de portátil (batería, brillo...) se crearán en la fase 3, con
  el mismo patrón (`empresa.portatil.enable`).
- **Comprobación**: con la VM aún llamada `nixos`, la derivación del sistema
  debe salir idéntica antes y después (aquí no se mueven listas de paquetes).
  El renombrado (`renombrar-vm.md`) va después, porque sí cambia el sistema.

## Plan
- [x] `modules/nixos/vm.nix` con `empresa.vm.enable`
- [x] `modules/nixos/gnome.nix` con `empresa.gnome.enable`
- [x] Quitar `spice-vdagent` de `modules/home/escritorio.nix`
- [x] El host activa las dos opciones
- [x] Comprobar que la derivación del sistema es idéntica
- [x] Documentar el patrón en `CLAUDE.md`

## Resultado
Derivación del sistema **idéntica** antes y después
(`501fqxi69a52a0rajx4cs962l5a369hc-nixos-system-...`): la VM no cambia nada.

Comprobado también el caso contrario (un equipo sin las opciones, evaluado con
`extendModules` y `mkForce false`): sin SPICE, sin QEMU, sin GNOME, sin perfil
dconf y la sesión de bspwm sin `spice-vdagent`. Al evaluarlo, NixOS avisa de
que sin GNOME hay que configurar `xdg.portal.config` (qué portal usar para los
diálogos de abrir archivo, etc.): apuntado para la fase 3 en `flota-equipos.md`.
