# Brais: su cuenta en el sistema y su configuración de Home Manager.
# Se añade a un equipo con mkHost en flake.nix.

{
  users.users.brais = {
    isNormalUser = true;
    description = "Brais";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  home-manager.users.brais = import ./home.nix;
}
