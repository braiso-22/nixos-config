# Ideas sueltas

Cosas que se han propuesto pero aún no son una tarea. Cuando se decida hacer
una, se crea su propio archivo en `todo/`.

- **nh**: sustituto de `nixos-rebuild`; enseña qué paquetes cambian antes de
  aplicar y limpia generaciones viejas (`programs.nh` con `clean.enable`).
- **Limpieza automática** de generaciones viejas y de `/nix/store`
  (`nix.gc.automatic`, `nix.optimise.automatic`): la VM tiene 41 GB de disco.
- **atuin**: historial de bash más potente que fzf (por carpeta, por resultado).
  Se descartó en la fase 2 para no complicar.
- **tmux o zellij**: paneles y sesiones en la terminal que sobreviven al cerrarla.
- **yazi**: explorador de archivos en la terminal.
- **comma** (`, programa`): ejecutar cualquier programa sin instalarlo. Necesita
  el flake `nix-index-database`.
- **Docker o Podman**: contenedores, si hacen falta para el trabajo.
- **Neovim**: si algún día se quiere un editor de terminal serio.
