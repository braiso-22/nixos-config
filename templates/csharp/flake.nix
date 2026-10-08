# Entorno del proyecto C# (plantilla de ~/nixos-config).
# direnv lo carga al entrar en la carpeta (.envrc: "use flake").
# Abre VS Code desde aquí (code --profile csharp .) para que encuentre .NET.
{
  description = "Proyecto C#";

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
      devShells = paraCadaSistema (
        pkgs:
        let
          dotnet = pkgs.dotnet-sdk_10; # LTS
        in
        {
          default = pkgs.mkShell {
            packages = [ dotnet ];
            # La extensión C# de VS Code y otras herramientas buscan .NET aquí.
            DOTNET_ROOT = "${dotnet}/share/dotnet";
          };
        }
      );
    };
}
