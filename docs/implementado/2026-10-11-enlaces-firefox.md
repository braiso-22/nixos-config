# Enlaces que no abren Firefox

- **Estado:** implementado
- **Fecha:** 2026-10-11 → 2026-10-11
- **Commit / tag:** ver tag 0.8.1

## Contexto
Al hacer clic en un enlace en el panel de terminal de la app de Claude no
pasa nada. Diagnóstico:
- `xdg-open` funciona y elige bien `firefox.desktop` (mimeapps.list correcto).
- Firefox no arranca: `libnss3.so: version 'NSS_3.113' not found`, y sale
  sin mostrar nada.
- Causa: el lanzador de la app de Claude (flake `claude-desktop`) define
  `LD_LIBRARY_PATH` con sus librerías (entre ellas `nss` 3.112.5). Todo lo
  que se abre desde la app lo hereda (terminal, enlaces del chat), y
  `LD_LIBRARY_PATH` manda sobre las librerías que Firefox lleva fijadas
  (`nss_latest`). El lanzador de Firefox hace `--prefix LD_LIBRARY_PATH`, que
  añade las suyas pero deja las heredadas.
- Desde alacritty no pasa (allí no existe esa variable).

## Decisiones
- Arreglarlo en Firefox, no en Claude: un `--unset LD_LIBRARY_PATH` al
  principio de los `makeWrapperArgs` del lanzador de Firefox
  (`programs.firefox.package` con `overrideAttrs`). Cubre cualquier programa
  que abra Firefox con el entorno ensuciado. En NixOS esa variable está vacía
  normalmente, así que no cambia nada en el caso normal.
- Descartado limpiar la variable en `.bashrc`: los enlaces los abre la propia
  app (Electron), no bash, así que no lo arreglaría.

## Plan
- [x] `programs.firefox.package` con el `--unset`
- [x] `dry-build`, aplicar y probar un enlace desde el terminal de Claude
- [x] Commit

## Resultado
- `dry-build`: 2,6 MiB de descarga (herramientas para rehacer el lanzador;
  Firefox no se recompila). `switch` en 22 s.
- Probado antes de aplicar con el entorno de la app de Claude: el Firefox
  viejo fallaba con el error de NSS y el nuevo arrancaba. Tras aplicar, los
  enlaces del terminal de Claude abren Firefox.
- El fallo de fondo es del flake `claude-desktop` (deja escapar su
  `LD_LIBRARY_PATH` a lo que abre). Otro programa abierto desde la app podría
  fallar igual: si pasa, mismo arreglo o avisar a ese proyecto.
