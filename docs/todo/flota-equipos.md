# Usar este repo en todos los portátiles de la empresa

- **Estado:** pendiente (diseño)
- **Fecha:** 2026-10-11 (inicio)
- **Commit / tag:** —

## Contexto
Hoy el repo configura una sola máquina (la VM aarch64 de brais). Se quiere que
todos los equipos del trabajo usen este setup como base, cada uno con su
usuario y su hardware, gestionado por una persona. Los cambios se proponen por
PR; nadie puede cambiar su sistema ni instalar software por su cuenta.

## Decisiones
- **Equipos:** portátiles (x86_64 casi seguro; la VM es aarch64).
- **Repo:** el de GitHub es público y personal. En la empresa se hará un
  **fork privado en Azure Repos**. Consecuencias:
  - Los portátiles necesitan una credencial para leerlo (PAT o clave SSH de
    solo lectura), guardada como secreto (sops-nix o agenix).
  - Azure Repos no tiene CODEOWNERS: lo equivalente es la *branch policy*
    "Automatically included reviewers" por ruta. Las políticas de rama son
    gratis (en GitHub privado requieren plan de pago).
  - La CI sería Azure Pipelines (compilar todos los hosts en cada PR).
- **Estructura:** `modules/nixos` + `modules/home` (lo común), `hosts/<pc>/`
  (`default.nix` + `hardware-configuration.nix`) y `users/<persona>/` (cuenta +
  `home.nix`). Persona y máquina separadas para reutilizar al cambiar de PC.
- **Apps comunes y por usuario:** comunes en `modules/home`, las de cada
  persona en `users/<persona>/home.nix` (por persona, no por departamento).
- **Todos programan** (también diseño, que usa npm): no hay modo "estricto";
  todos con el mismo bloqueo:
  - sin `wheel` ni `trusted-users`; cuenta de administrador aparte;
  - sin Flatpak ni `nix-ld`;
  - VS Code con `/etc/vscode/policy.json` (`AllowedExtensions`) generado desde
    las listas de `vscode.nix`; políticas del navegador;
  - Nix sigue permitido a los usuarios porque los devShells (npm, JDK, .NET)
    lo necesitan. Se acepta que técnicamente podrían instalarse cosas con él.
- **Escritorio:** solo bspwm en los portátiles del equipo (sin GNOME).
- **IntelliJ fuera del repo** (ver `quitar-intellij.md`).
- **Contenedores:** se usarán para desarrollar. Siempre **sin root**
  (el grupo `docker` equivale a root y rompería el bloqueo): **Docker
  rootless** (ver `docker-rootless.md`).
- **Número de portátiles:** unos 10.
- **Actualizaciones:** por *pull* (los portátiles no siempre están encendidos
  ni localizables): `system.autoUpgrade` desde el repo, con `persistent`, más
  un "botón" (polkit) para forzarla. Más adelante, quizá comin.

## Pendiente de decidir
- Cifrado de disco (LUKS): muy recomendable en portátiles.

## Plan (por fases)
- [x] Reorganizar el repo en `modules/`, `hosts/` y `users/` sin cambios
      funcionales (la VM como primer host)
- [x] Opciones propias `empresa.*` para lo opcional (`empresa.vm`, `empresa.gnome`)
- [ ] Lo que bspwm no trae y un portátil necesita: batería en polybar, Wi-Fi
      (nm-applet), brillo y volumen en sxhkd, suspender al cerrar la tapa,
      monitores externos (autorandr), ahorro de energía, `xdg.portal.config`
      (sin GNOME, NixOS avisa de que falta elegir el portal)
- [x] Contenedores sin root (Docker rootless)
- [ ] Bloqueo: usuarios sin `wheel`, sin `nix-ld`, política de VS Code
- [ ] `system.autoUpgrade` desde el repo y botón de actualizar
- [ ] CI que compile todos los hosts + caché binaria (Attic/Cachix)
- [ ] Secretos (credencial del repo, Wi-Fi, VPN)
- [ ] Primer portátil real
