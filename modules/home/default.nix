# Lo común de Home Manager: lo tienen todas las personas de todos los equipos
# (cada users/<persona>/home.nix lo importa).
# Lo de cada persona va en users/<persona>/home.nix.

{
  imports = [
    ./terminal.nix # bash, git, gh y herramientas de terminal
    ./vscode.nix # VS Code con perfiles por lenguaje
    ./nuevo-proyecto.nix # comando nuevo-proyecto (plantillas de templates/)
    ./escritorio.nix # escritorio bspwm (polybar, rofi, picom...)
  ];
}
