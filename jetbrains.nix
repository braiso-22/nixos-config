# IDEs de JetBrains desde nixpkgs (lo importa home.nix). La versión la fija
# flake.lock y se actualiza con nix flake update nixpkgs, igual que el resto.
#
# Abre el IDE desde la carpeta del proyecto (idea .) para que herede el
# entorno de direnv (JDK, Gradle...) del devShell.

{ pkgs, ... }:

{
  home.packages = [
    pkgs.jetbrains.idea # IntelliJ IDEA (Kotlin, Java)
  ];
}
