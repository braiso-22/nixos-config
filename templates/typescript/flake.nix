# Entorno del proyecto TypeScript (plantilla de ~/nixos-config).
# direnv lo carga al entrar en la carpeta (.envrc: "use flake").
# TypeScript, ESLint, etc. van en package.json del proyecto (pnpm add -D ...).
{
  description = "Proyecto TypeScript";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      sistemas = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];
      paraCadaSistema = f: nixpkgs.lib.genAttrs sistemas (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = paraCadaSistema (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.nodejs_24 # LTS
            pkgs.pnpm
          ];
        };
      });
    };
}
