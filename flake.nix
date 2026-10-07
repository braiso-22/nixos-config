{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    claude-desktop.url = "github:poeck/claude-desktop-nix-flake";
    # Home Manager: configuración del usuario (dotfiles) declarada en home.nix.
    # La rama release-26.05 va a juego con nixpkgs, y "follows" hace que use
    # el mismo nixpkgs que el sistema en vez de descargar otro.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      claude-desktop,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          claude-desktop.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true; # usa el mismo pkgs (y allowUnfree) que el sistema
              useUserPackages = true; # instala los paquetes del usuario en su perfil
              # Si ya existe un archivo que Home Manager quiere crear, lo renombra
              # a *.hm-backup en vez de fallar.
              backupFileExtension = "hm-backup";
              users.brais = import ./home.nix;
            };
          }
        ];
      };
    };
}
