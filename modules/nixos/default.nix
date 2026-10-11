# Lo común del sistema: lo llevan todos los equipos (flake.nix, mkHost).

{ inputs, ... }:

{
  imports = [
    ./sistema.nix # arranque, red, idioma, teclado, sonido, Nix
    ./escritorio.nix # X11, LightDM, sesión bspwm, bloqueo de pantalla
    ./programas.nix # Firefox, git, Claude, Docker rootless
    inputs.claude-desktop.nixosModules.default
    inputs.stylix.nixosModules.stylix # también aplica el tema en Home Manager
    ./tema.nix
    inputs.home-manager.nixosModules.home-manager
    ./home-manager.nix
  ];
}
