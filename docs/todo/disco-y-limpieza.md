# Agrandar el disco y limpieza automática

- **Estado:** en curso
- **Fecha:** 2026-10-08
- **Commit / tag:** —

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
- **Agrandar el disco** a **100 GB** (sugerido; depende del espacio libre en
  el Mac). El disco de UTM (qcow2) solo ocupa en el Mac lo que se usa de
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
- [ ] Apagar la VM y agrandar el disco en UTM (pasos en "Pasos en UTM")
- [ ] Encender y ampliar partición + sistema de archivos (pasos abajo)
- [ ] Comprobar con `df -h /` y cerrar la tarea (tag)

### Pasos en UTM (Mac, VM apagada)
1. En UTM, selecciona la VM → botón de editar (icono de ajustes).
2. En la barra lateral, en **Drives**, elige el disco VirtIO (42 GB).
3. Pulsa **Resize…**, pon el tamaño nuevo (p. ej. 100 GB) y confirma.
4. Guarda y arranca la VM.

### Pasos en NixOS (VM encendida)
```bash
lsblk /dev/vda                      # vda debe mostrar el tamaño nuevo; vda2 aún 41G
nix shell nixpkgs#cloud-utils --command sudo growpart /dev/vda 2   # amplía la partición 2
sudo resize2fs /dev/vda2            # amplía el sistema de archivos ext4
df -h /                             # debe mostrar el tamaño nuevo
```

## Resultado
