# Ajustes globales de Home Manager. La configuración de cada persona se
# engancha en users/<persona>/default.nix.

{
  home-manager = {
    useGlobalPkgs = true; # usa el mismo pkgs (y allowUnfree) que el sistema
    useUserPackages = true; # instala los paquetes del usuario en su perfil
    # Si ya existe un archivo que Home Manager quiere crear, lo renombra
    # a *.hm-backup en vez de fallar.
    backupFileExtension = "hm-backup";
  };
}
