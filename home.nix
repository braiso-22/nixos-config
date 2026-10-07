# Configuración del usuario brais con Home Manager: programas de usuario y
# sus dotfiles (~/.config/...). Se aplica con el mismo nixos-rebuild switch.
# Opciones disponibles: https://home-manager-options.extranix.com/?release=release-26.05

{ config, pkgs, lib, ... }:

{
  home.username = "brais";
  home.homeDirectory = "/home/brais";

  programs.git = {
    enable = true;
    settings = {
      user.name = "brais";
      user.email = "braisfv22@gmail.com";
      init.defaultBranch = "main";
    };
  };

  # GitHub CLI. gitCredentialHelper hace que git use gh para autenticarse en
  # GitHub (antes estaba en ~/.gitconfig con una ruta fija de /nix/store que
  # se rompería al actualizar gh).
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };

  # Versión de Home Manager con la que se creó esta configuración.
  # Igual que system.stateVersion: no se cambia nunca.
  home.stateVersion = "26.05";
}
