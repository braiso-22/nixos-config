# Agrandar el disco y limpieza automática

- **Estado:** implementado
- **Fecha:** 2026-10-08 → 2026-10-09
- **Commit / tag:** 21f5e3e (limpieza automática), cierre: ver tag 0.6.0

## Contexto
El disco de la VM es de 41 GB y en la fase 3 se llenó al instalar IntelliJ
(pico de ~19 GB al prepararlo). Se liberaron 17,5 GiB a mano borrando 9
generaciones antiguas (`nix-env --delete-generations +3`) y con
`nix-collect-garbage`. Hoy: ~24 GB usados, ~15 GB libres. Antes de la fase 4
(escritorio) se quiere más margen y que la limpieza no dependa de acordarse.

Situación del disco: `/dev/vda` 42 GB, `vda1` 1 GB EFI (`/boot`, 87 MB
usados), `vda2` 41 GB ext4 (`/`), **última partición del disco**.

## Decisiones
- **Limpieza automática** en `configuration.nix`:
  - `nix.gc`: semanal, borra generaciones de **más de 14 días** (ventana de 2
    semanas para volver atrás) y lo que no use nada. `persistent` (por
    defecto) hace que, si la VM estaba apagada a la hora programada, se
    ejecute al arrancar.
  - `nix.optimise.automatic`: semanal, deduplica la tienda de Nix con enlaces
    duros (archivos idénticos ocupan una sola vez). Preferido a
    `nix.settings.auto-optimise-store`, que lo hace en cada compilación y
    ralentiza las grandes (IntelliJ).
  - `boot.loader.systemd-boot.configurationLimit = 10`: el menú de arranque
    y `/boot` guardan como mucho 10 generaciones.
  - Los entornos de proyecto (direnv) no se borran: nix-direnv los protege.
- **Agrandar el disco**: se sugirieron 100 GB, pero el Mac no tiene tanto
  libre: **se amplió a 50 GB (+8 GB)**. El disco de UTM (qcow2) solo ocupa en el Mac lo que se usa de
  verdad, pero no conviene darle más de lo que el Mac tiene libre.
  - Primero en UTM, con la VM apagada; luego, en NixOS, ampliar la partición
    y el sistema de archivos **en caliente** (ext4 lo permite):
    `growpart` (de `cloud-utils`, vía `nix shell nixpkgs#cloud-utils`, que usa
    el nixpkgs del sistema) + `resize2fs`.
  - Hecho a mano una vez, no con `boot.growPartition` /
    `fileSystems."/".autoResize`: es una operación puntual y así no queda
    magia permanente en la configuración.
  - Riesgo bajo, pero antes: todo el repo está en GitHub; los datos de `~`
    (proyectos) no. Si hay algo importante sin subir, subirlo antes.

## Plan
- [x] Limpieza automática en `configuration.nix`, `dry-build` (5,8 KiB), aplicar:
      temporizadores `nix-gc.timer` y `nix-optimise.timer` activos (primera
      pasada el lunes 2026-10-12 00:00)
- [x] Commit y push (antes de apagar la VM)
- [x] Apagar la VM y agrandar el disco en UTM (50 GB) (pasos en "Pasos en UTM")
- [x] Encender y ampliar partición + sistema de archivos (pasos abajo)
- [x] Comprobar con `df -h /` y cerrar la tarea (tag)

### Pasos en UTM (Mac, VM apagada)
1. En UTM, selecciona la VM → botón de editar (icono de ajustes).
2. En la barra lateral, en **Drives**, elige el disco VirtIO (42 GB).
3. Pulsa **Resize…**, pon el tamaño nuevo (p. ej. 100 GB) y confirma.
4. Guarda y arranca la VM.

### Pasos en NixOS (VM encendida)
```bash
lsblk /dev/vda                      # vda debe mostrar el tamaño nuevo; vda2 aún 41G
sudo $(nix build --no-link --print-out-paths nixpkgs#cloud-utils)/bin/growpart /dev/vda 2   # amplía la partición 2 (ruta completa: sudo podría no ver el PATH de nix shell)
sudo resize2fs /dev/vda2            # amplía el sistema de archivos ext4
df -h /                             # debe mostrar el tamaño nuevo
```

## Resultado
- Primera deduplicación lanzada a mano (`sudo systemctl start nix-optimise.service`,
  2026-10-09): **844,7 MiB** liberados enlazando 154 350 archivos, en ~12 min.
  Disco: 23 GB usados, 16 GB libres (antes de agrandarlo).
- Disco agrandado en UTM a 50 GB. `growpart /dev/vda 2`: `CHANGED` (vda2
  41 → 49 GB). `resize2fs /dev/vda2` en caliente, sin reiniciar. Resultado:
  **48 GB, 23 GB usados, 23 GB libres**.
- `nix shell nixpkgs#cloud-utils --command sudo growpart` no se usó: no se pudo
  comprobar si `sudo` conserva el PATH, así que se llamó con ruta completa.
