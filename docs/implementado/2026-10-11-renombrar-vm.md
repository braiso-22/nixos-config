# Renombrar la VM a test-nixos-vm

- **Estado:** implementado
- **Fecha:** 2026-10-11 (inicio) → 2026-10-11 (fin)
- **Commit / tag:** ver tag 0.11.0

## Contexto
La VM se llama `nixos` (hostname y `nixosConfigurations.nixos`), el nombre
que pone el instalador. Con unos 10 portátiles en el repo hace falta un nombre
que diga qué es. El usuario elige `test-nixos-vm`: es la máquina de pruebas.

## Decisiones
- Cambian a la vez el hostname, el nombre en `flake.nix` y la carpeta
  `hosts/test-nixos-vm/`: los tres iguales para no confundirse.
- **El alias `rebuild` deja de llevar el nombre**: `nixos-rebuild switch
  --flake ~/nixos-config` sin `#nombre` usa el hostname de la máquina, así que
  sirve igual en todos los equipos. El primer `switch` sí tiene que llevar
  `#test-nixos-vm`, porque en ese momento el hostname aún es `nixos`.
- Tras el `switch` hay que **reiniciar**: X11 guarda sus permisos de acceso
  (xauth) con el hostname, y en la sesión ya abierta podrían dejar de abrirse
  ventanas nuevas.
- Se actualizan los comandos de `CLAUDE.md` y de la skill `anadir-paquete`.
  Los documentos de `docs/implementado/` no se tocan: cuentan lo que pasó.

## Plan
- [x] `git mv hosts/nixos hosts/test-nixos-vm`, hostname y `flake.nix`
- [x] Alias `rebuild` sin nombre
- [x] Comandos de `CLAUDE.md` y de la skill
- [x] `dry-build`, aplicar con `#test-nixos-vm` y reiniciar

## Resultado
`dry-build`: 4,1 KiB de descarga y 49 derivaciones que se generan en local.
Comparado con el sistema anterior, solo cambia lo que lleva el nombre:
`/etc/hostname`, `/etc/hosts`, el initrd (que guarda el hostname), avahi y el
alias `rebuild` (`bashrc` y archivos de Home Manager).

Aplicado con `switch --flake ~/nixos-config#test-nixos-vm` (23 s) y reinicio:
`hostname` da `test-nixos-vm`, ningún servicio fallido, `spice-vdagent` en
marcha en la sesión de bspwm y LightDM sigue ofreciendo bspwm y GNOME.
