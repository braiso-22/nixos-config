# Docker sin root (rootless)

- **Estado:** implementado
- **Fecha:** 2026-10-11 (inicio) → 2026-10-11 (fin)
- **Commit / tag:** ver tag 0.9.0

## Contexto
Fase "Contenedores sin root" de `flota-equipos.md`. En los portátiles se
desarrollará con contenedores, pero los usuarios no tendrán `wheel` y el grupo
`docker` equivale a root (quien puede hablar con el demonio de Docker normal
puede montar `/` en un contenedor y hacer lo que quiera). Se prueba primero en
la VM, en `configuration.nix`; al reorganizar el repo pasará a `modules/nixos`.

## Decisiones
- **Docker rootless y no Podman:** es Docker de verdad (`docker`,
  `docker compose`, Dev Containers de VS Code, Testcontainers...) sin
  diferencias de comportamiento; con Podman habría que lidiar con su emulación
  de la API de Docker y las diferencias de `podman-compose`.
- `virtualisation.docker.rootless.enable`: un demonio `dockerd` **por usuario**
  (servicio de systemd de usuario), que corre con los permisos de ese usuario.
  Sin `virtualisation.docker.enable` (el demonio con root) y sin grupo `docker`.
- `setSocketVariable = true`: define `DOCKER_HOST` apuntando al socket del
  usuario (`$XDG_RUNTIME_DIR/docker.sock`), así `docker` y VS Code lo
  encuentran sin configurar nada.
- El paquete `docker` de nixpkgs ya trae `docker compose` y `docker buildx`.
- Las imágenes se guardan en `~/.local/share/docker` de cada usuario.
- Limitaciones conocidas de rootless (aceptadas): no puede abrir puertos
  < 1024 en el host (usar 8080 en vez de 80, etc.) y `--net=host` no expone
  puertos del host real.
- Sin limpieza automática de imágenes por ahora (`docker system prune` borraría
  contenedores parados que el usuario quizá quiere). Si el disco se llena, se
  verá entonces.

## Plan
- [x] Activar `virtualisation.docker.rootless` en `configuration.nix`
- [x] `dry-build` y tamaño de descarga
- [x] Aplicar y probar: `docker run --rm hello-world`, `docker compose version`,
      comprobar que el demonio corre como `brais` y no como root

## Resultado
Docker rootless activo en la VM. Descarga del `switch`: 136,7 MiB (436 MiB
en disco); todo viene de la caché, solo se generan archivos de configuración.

Comprobado:
- `systemctl --user status docker`: el servicio arranca solo al iniciar sesión.
- `ps -o user,cmd -C dockerd`: el demonio corre como `brais`, no como root.
- `docker info`: modo `rootless`, imágenes en `/home/brais/.local/share/docker`.
- `docker run --rm hello-world` y `docker compose version` (5.4.0) funcionan.
- `docker run -p 8080:80 nginx:alpine` responde en `localhost:8080`.

`DOCKER_HOST` se define en `/etc/set-environment`, que se carga al iniciar
sesión: tras el primer `switch` hay que cerrar sesión y volver a entrar (o
abrir una terminal nueva desde una sesión nueva) para que `docker` lo encuentre.
