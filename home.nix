# Configuración del usuario brais con Home Manager: programas de usuario y
# sus dotfiles (~/.config/...). Se aplica con el mismo nixos-rebuild switch.
# Opciones disponibles: https://home-manager-options.extranix.com/?release=release-26.05

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./vscode.nix # VS Code con perfiles por lenguaje
    ./jetbrains.nix # IntelliJ IDEA
  ];

  home.username = "brais";
  home.homeDirectory = "/home/brais";

  programs.git = {
    enable = true;
    settings = {
      user.name = "brais";
      user.email = "braisfv22@gmail.com";
      init.defaultBranch = "main";
    };
  };

  # GitHub CLI. gitCredentialHelper hace que git use gh para autenticarse en
  # GitHub (antes estaba en ~/.gitconfig con una ruta fija de /nix/store que
  # se rompería al actualizar gh).
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };

  # ── Terminal ────────────────────────────────────────────────────────────

  # Fuente con iconos (Nerd Font): la necesitan starship y eza para los iconos.
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nixfmt # formateador oficial de Nix: nixfmt archivo.nix
  ];
  fonts.fontconfig.enable = true;

  # GNOME Console (kgx) usa la fuente monoespaciada del sistema.
  dconf.settings."org/gnome/desktop/interface".monospace-font-name = "JetBrainsMono Nerd Font 11";

  programs.bash = {
    enable = true;
    enableCompletion = true;
    historySize = 10000; # comandos en memoria
    historyFileSize = 100000; # comandos guardados en ~/.bash_history
    # Sin duplicados; un comando que empieza por espacio no se guarda.
    historyControl = [
      "erasedups"
      "ignorespace"
    ];
    shellOptions = [
      "histappend" # varias terminales abiertas no se pisan el historial
      "checkwinsize"
      "globstar" # ** busca en subcarpetas: ls **/*.nix
      "autocd" # escribir el nombre de una carpeta entra en ella
      "cdspell" # corrige erratas pequeñas en cd
    ];
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      lg = "lazygit";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    };
  };

  # Prompt con la rama de git, versión del lenguaje del proyecto, tiempo del
  # último comando si tarda, etc.
  programs.starship.enable = true;

  # ls moderno con colores, iconos y estado de git. Crea los alias ls, ll, la, lt (árbol).
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  programs.bat.enable = true; # cat con resaltado de sintaxis: bat archivo
  programs.ripgrep.enable = true; # rg: grep mucho más rápido, respeta .gitignore
  programs.fd.enable = true; # fd: find más sencillo: fd nombre
  programs.jq.enable = true; # procesar JSON en la terminal
  programs.btop.enable = true; # monitor de CPU/memoria/procesos

  # Búsqueda difusa: Ctrl+R historial, Ctrl+T archivos, Alt+C carpetas.
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
  };

  # z <trozo de nombre>: salta a carpetas que ya has visitado. zi = interactivo.
  programs.zoxide.enable = true;

  # Entornos por proyecto: al entrar en una carpeta con .envrc ("use flake")
  # se cargan sus herramientas; al salir se descargan.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };

  programs.lazygit.enable = true; # git con interfaz en la terminal (alias lg)

  # Diffs de git con colores y resaltado de sintaxis.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true; # n / N para saltar entre archivos
      line-numbers = true;
    };
  };

  # tldr <comando>: ejemplos prácticos y cortos.
  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  # Versión de Home Manager con la que se creó esta configuración.
  # Igual que system.stateVersion: no se cambia nunca.
  home.stateVersion = "26.05";
}
