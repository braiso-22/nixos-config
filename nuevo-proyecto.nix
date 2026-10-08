# Comando nuevo-proyecto (lo importa home.nix): prepara el entorno de un
# proyecto con una plantilla de templates/ en la carpeta actual.
#
#   cd mi-proyecto && nuevo-proyecto kotlin   (o typescript, csharp)
#
# Fija la misma versión de nixpkgs que el sistema, para reutilizar lo ya
# instalado en vez de descargarlo de nuevo (p. ej. Kotlin: 94 MiB en vez de
# 627). El flake.lock apunta a GitHub, así que el proyecto sirve en otra máquina.

{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "nuevo-proyecto";
      runtimeInputs = [
        pkgs.git
        pkgs.direnv
      ];
      text = ''
        lenguajes="kotlin typescript csharp"
        if [ $# -ne 1 ] || [[ " $lenguajes " != *" $1 "* ]]; then
          echo "Uso: nuevo-proyecto <lenguaje>   (lenguajes: $lenguajes)" >&2
          exit 1
        fi

        # nix y nixos-version son del sistema (ya están en el PATH).
        if ! salida=$(nix flake init -t "$HOME/nixos-config#$1" 2>&1); then
          echo "$salida" >&2
          exit 1
        fi
        nix flake lock --override-input nixpkgs "github:NixOS/nixpkgs/$(nixos-version --revision)"

        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git add flake.nix flake.lock .envrc # Nix solo ve archivos añadidos a git
          if ! grep -qxF '.direnv/' .gitignore 2>/dev/null; then
            echo '.direnv/' >>.gitignore
          fi
        fi

        direnv allow
        echo "Entorno de $1 listo. Al entrar en esta carpeta se carga solo."
      '';
    })
  ];
}
