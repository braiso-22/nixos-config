# Home Manager de brais: solo lo suyo. Lo común está en modules/home.
# Opciones disponibles: https://home-manager-options.extranix.com/?release=release-26.05

{
  imports = [
    ../../modules/home # lo común de todos los usuarios
  ];

  home.username = "brais";
  home.homeDirectory = "/home/brais";

  programs.git.settings.user = {
    name = "brais";
    email = "braisfv22@gmail.com";
  };

  # Versión de Home Manager con la que se creó esta configuración.
  # Igual que system.stateVersion: no se cambia nunca.
  home.stateVersion = "26.05";
}
