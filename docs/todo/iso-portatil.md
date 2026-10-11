# ISO de prueba para el portátil (arranque desde USB)

- **Estado:** en curso
- **Fecha:** 2026-10-11 (inicio)
- **Commit / tag:** —

## Contexto
La fase 3 de `flota-equipos.md` (batería, Wi-Fi, brillo, tapa, monitores...)
no se puede probar en la VM: no tiene ese hardware. Se quiere probar en un
portátil real **sin instalar nada**: una ISO propia, construida desde este
repo, que arranca desde un USB con el escritorio de la empresa (bspwm, SDDM,
polybar, atajos, programas). Al apagar no queda nada en el portátil.

El portátil es un **ASUS ROG Strix con NVIDIA** (modelo exacto y Wi-Fi
desconocidos). Los ROG Strix suelen tener gráficos híbridos (integrada AMD o
Intel + NVIDIA, con MUX), y configurar la NVIDIA bien (PRIME) necesita las
direcciones PCI de las dos gráficas, que solo se ven en el propio portátil.

## Decisiones
- **Dos vueltas:**
  1. ISO de **reconocimiento**: escritorio común con los controladores libres
     del kernel (nouveau para la NVIDIA) y todo el firmware
     (`hardware.enableAllFirmware`), más un comando `info-portatil` que recoge
     modelo, gráficas, Wi-Fi, batería, monitores y el
     `hardware-configuration.nix`.
  2. ISO con la NVIDIA bien configurada para ese modelo (seguramente con
     `nixos-hardware`) y lo de la fase 3 (`empresa.portatil`).
- **Se construye en GitHub Actions**, no en la VM: los portátiles son x86_64 y
  la VM es aarch64 (habría que emular x86, lento, y descargar varios GB con
  30 GB libres). Las máquinas x86_64 de GitHub son gratis en repos públicos.
  Flujo manual (`workflow_dispatch`): se lanza con un botón o `gh workflow run`
  y deja la ISO como *artifact* descargable (7 días). Es el primer paso de la
  fase de CI.
- La ISO es **pública** (repo público): no puede llevar secretos. Ahora no los
  hay.
- Host nuevo `hosts/iso-portatil/` con el módulo oficial
  `installation-cd-base.nix` (imagen ISO + herramientas de instalación) y la
  plataforma `x86_64-linux`. Usa `mkHost` como cualquier equipo, con el usuario
  `brais`: así se prueba la configuración real de una persona.
- En la ISO: entrada automática en bspwm (SDDM `autoLogin`), contraseña de
  prueba conocida para `brais` (para el bloqueo de pantalla; es pública, solo
  vale en el USB) y `sudo` sin contraseña (lo pone ya el módulo de la ISO).
- Sin GNOME ni `empresa.vm` (los portátiles no los llevan) y sin Docker (no
  hace falta para probar hardware y en un sistema de solo lectura daría error).
- Compresión `zstd` de nivel bajo: la ISO ocupa algo más pero se construye
  mucho antes en GitHub.
- Para pasarme lo que recoge `info-portatil`: `gh auth login` en el USB y
  `gh gist create --secret` (un gist secreto solo lo ve quien tiene el enlace);
  lo leo desde la VM con `gh`. El informe no incluye números de serie.
- **Secure Boot** debe estar desactivado en la BIOS: la ISO no está firmada.

## Plan
- [x] `hosts/iso-portatil/` + `info-portatil`
- [x] Salida `packages.x86_64-linux.iso-portatil` en `flake.nix`
- [x] Evaluar desde la VM y ver qué habría que construir
- [x] `.github/workflows/iso-portatil.yml`
- [ ] Commit, push y lanzar el flujo
- [ ] Descargar, grabar en USB (balenaEtcher) y arrancar el portátil
- [ ] `info-portatil` y pasarme el informe

## Resultado
Evaluada desde la VM: sin errores. Avisos resueltos: `xorg.xrandr` → `xrandr`
y sin ZFS (`boot.supportedFilesystems.zfs = mkForce false`: la ISO oficial lo
trae y no se usa). Queda el aviso de `xdg.portal` (fase 3).

`nix build --dry-run` en x86_64: 3,4 GiB de descarga (8,8 GiB descomprimido)
y 532 derivaciones que construir, todas ligeras (configuración, firmware,
reempaquetados de VS Code, Claude y Firefox). La VM no cambia.
