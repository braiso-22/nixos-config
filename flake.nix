{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    claude-desktop.url = "github:poeck/claude-desktop-nix-flake";
  };

  outputs = { nixpkgs, claude-desktop, ...} : {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        claude-desktop.nixosModules.default
      ];
    };
  };
}
