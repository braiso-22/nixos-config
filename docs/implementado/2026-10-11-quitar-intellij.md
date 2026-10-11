# Quitar IntelliJ IDEA

- **Estado:** implementado
- **Fecha:** 2026-10-11 → 2026-10-11
- **Commit / tag:** ver tag 0.8.0

## Contexto
IntelliJ se añadió en la fase 3 (`docs/implementado/2026-10-08-ides-desarrollo.md`).
El usuario pide quitarlo del repo: el setup se va a compartir con el equipo
(`flota-equipos.md`), donde no se usará, y es lo más pesado de instalar
(~19 GB de pico de disco al compilarlo).

## Decisiones
- Se borra `jetbrains.nix` y su import en `home.nix`.
- La plantilla `kotlin` se mantiene (JDK 25; se compila con `./gradlew` desde
  la terminal); solo cambian sus textos. Queda por decidir si se borra o si
  se añade Kotlin a VS Code.
- Los datos que IntelliJ dejó en el home (`~/.cache/JetBrains` 1,1 GB,
  `~/.local/share/JetBrains` 1,2 GB, `~/.config/JetBrains` 13 MB) no los
  borra Nix: los borra el usuario si quiere.
- El doc de la fase 3 no se toca: es histórico.

## Plan
- [x] Borrar `jetbrains.nix` y quitarlo de `home.nix`
- [x] Textos: plantilla kotlin, `flake.nix`, `vscode.nix`, `CLAUDE.md`
- [x] `dry-build` y aplicar
- [x] Commit

## Resultado
- `dry-build`: 0 descargas, solo 10 derivaciones pequeñas (generación de
  Home Manager). `switch` sin problemas (20 s); `idea` ya no está en el PATH.
- Limpieza: tras `sudo nix-collect-garbage -d` IntelliJ seguía en
  `/nix/store` (lo retenían `/run/booted-system` y la sesión abierta). Tras
  reiniciar, `nix-collect-garbage` liberó 6,5 GiB (IntelliJ 4,2 GB + JDKs).
  Más 2,3 GB de datos de JetBrains en el home, borrados a mano. Disco: de
  21 GB usados a 15 GB (31 GB libres).
- Ojo: el `-d` borró también el .NET SDK descargado antes (ningún proyecto
  lo anclaba); el primer proyecto C# lo volvió a descargar (308 MiB).
- Pendiente aparte: qué hacer con la plantilla `kotlin` (dejarla, borrarla o
  añadir Kotlin a VS Code).
