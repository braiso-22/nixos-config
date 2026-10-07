# VS Code con un perfil por lenguaje (lo importa home.nix).
#
# Cada perfil tiene sus extensiones y ajustes; todos comparten las listas
# "comunes" de abajo. VS Code recuerda qué perfil usa cada carpeta (se elige
# en el engranaje de abajo a la izquierda) o se abre con: code --profile csharp .
#
# Las extensiones solo se añaden aquí (no desde el marketplace de VS Code).
# Al aplicar un cambio que cree un perfil nuevo, VS Code debe estar cerrado.
#
# Kotlin no tiene perfil: se usa IntelliJ. Para extensiones que no estén en
# nixpkgs, ver la tarea de IDEs en docs/ (flake nix-vscode-extensions).

{
  config,
  pkgs,
  lib,
  ...
}:

let
  nixpkgsExt = pkgs.vscode-extensions;

  extensionesComunes = [
    nixpkgsExt.jnoortheen.nix-ide # archivos .nix (como este repo)
    nixpkgsExt.mkhl.direnv # carga el entorno del devShell del proyecto
    nixpkgsExt.eamodio.gitlens # historial y autoría de git en el editor
  ];

  ajustesComunes = {
    "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
    "editor.fontLigatures" = true; # => != === se ven como un símbolo
    "editor.fontSize" = 14;
    "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
    # Guardado automático tras 1 s sin escribir. Ese guardado no formatea:
    # formatOnSave solo actúa al guardar a mano (Ctrl+S).
    "files.autoSave" = "afterDelay";
    "editor.formatOnSave" = true;
    "telemetry.telemetryLevel" = "off";
    "extensions.ignoreRecommendations" = true; # no proponer instalar extensiones a mano
    # Nix: autocompletado y errores con el servidor de lenguaje nil.
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = lib.getExe pkgs.nil;
    # Formatear .nix con nixfmt (estilo oficial). nil ya lo usaba por defecto;
    # así queda explícito y con el mismo nixfmt que en la terminal.
    "nix.serverSettings".nil.formatting.command = [ (lib.getExe pkgs.nixfmt) ];
    # Recargar las extensiones cuando cambia el entorno de direnv.
    "direnv.restart.automatic" = true;
  };

  # Crea un perfil con las extensiones y ajustes comunes más los suyos.
  perfil =
    {
      extensiones ? [ ],
      ajustes ? { },
    }:
    {
      extensions = extensionesComunes ++ extensiones;
      userSettings = ajustesComunes // ajustes;
    };
in
{
  programs.vscode = {
    enable = true;
    profiles = {
      # Para el repo de NixOS y cosas sueltas.
      default = perfil { } // {
        enableUpdateCheck = false; # VS Code lo actualiza Nix
        enableExtensionUpdateCheck = false; # las extensiones también
      };

      typescript = perfil {
        extensiones = [
          nixpkgsExt.dbaeumer.vscode-eslint
          nixpkgsExt.esbenp.prettier-vscode
        ];
        ajustes."editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      csharp = perfil {
        extensiones = [
          nixpkgsExt.ms-dotnettools.vscode-dotnet-runtime
          nixpkgsExt.ms-dotnettools.csharp
          nixpkgsExt.ms-dotnettools.csdevkit
        ];
      };
    };
  };
}
