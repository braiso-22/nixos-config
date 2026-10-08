# Entorno del proyecto Kotlin (plantilla de ~/nixos-config).
# direnv lo carga al entrar en la carpeta (.envrc: "use flake").
# Abre IntelliJ desde aquí (idea .) para que use este JDK.
{
  description = "Proyecto Kotlin";

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
          # Gradle no va aquí: cada proyecto trae el suyo con ./gradlew.
          # El JDK pone JAVA_HOME, y Gradle lo usa como toolchain.
          packages = [ pkgs.jdk25 ];
        };
      });
    };
}
