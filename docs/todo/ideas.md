# Ideas sueltas

Cosas que se han propuesto pero aún no son una tarea. Cuando se decida hacer
una, se crea su propio archivo en `todo/`.

- **nh**: sustituto de `nixos-rebuild`; enseña qué paquetes cambian antes de
  aplicar y limpia generaciones viejas (`programs.nh` con `clean.enable`).
- **Limpieza automática** de generaciones viejas y de `/nix/store`
  (`nix.gc.automatic`, `nix.optimise.automatic`): la VM tiene 41 GB de disco.
- **Agrandar el disco de la VM** (41 GB → 80–100 GB): con IntelliJ y la
  limpieza manual ya se llenó una vez (fase 3). Se hace con la VM apagada en
  UTM (Mac) y luego, en NixOS, ampliar la partición `/dev/vda2` (ext4,
  última partición del disco) con `growpart` + `resize2fs`.
- **atuin**: historial de bash más potente que fzf (por carpeta, por resultado).
  Se descartó en la fase 2 para no complicar.
- **tmux o zellij**: paneles y sesiones en la terminal que sobreviven al cerrarla.
- **yazi**: explorador de archivos en la terminal.
- **comma** (`, programa`): ejecutar cualquier programa sin instalarlo. Necesita
  el flake `nix-index-database`.
- **Docker o Podman**: contenedores, si hacen falta para el trabajo.
- **Neovim**: si algún día se quiere un editor de terminal serio.
- **Compartir el setup con un equipo** (~10 personas, gestionado por una sola
  persona). Hoy el repo es para una máquina y un usuario (`brais`). Habría que:
  separar lo común en módulos reutilizables y dejar por máquina solo lo suyo
  (`hardware-configuration.nix`, hostname, usuario); decidir cómo se reparten
  las actualizaciones (cada uno hace `switch` del repo, o despliegue remoto);
  montar una **caché binaria propia** (Attic/Cachix) para que los paquetes no
  libres (VS Code, IntelliJ, extensiones) se descarguen una vez y no en cada
  máquina; y gestionar licencias de JetBrains del equipo.
