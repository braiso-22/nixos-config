# Programas del sistema comunes a todos los equipos. Las herramientas de cada
# usuario van en Home Manager (modules/home).

{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    # La app de Claude define LD_LIBRARY_PATH con sus librerías y todo lo que
    # abre lo hereda (enlaces del chat y de su terminal). Con una nss antigua
    # ahí, Firefox se cierra sin avisar. Su lanzador la vacía antes de poner
    # las suyas (normalmente ya está vacía, así que no cambia nada más).
    package = pkgs.firefox.overrideAttrs (old: {
      makeWrapperArgs = [
        "--unset"
        "LD_LIBRARY_PATH"
      ]
      ++ old.makeWrapperArgs;
    });
  };
  programs.git.enable = true; # a nivel de sistema (lo usa root); la del usuario está en modules/home/terminal.nix
  programs.claude-desktop.enable = true;

  # Docker sin root: cada usuario tiene su propio demonio, que corre con sus
  # permisos. No se usa el grupo "docker" (equivale a root).
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true; # DOCKER_HOST apunta al socket del usuario
  };
}
