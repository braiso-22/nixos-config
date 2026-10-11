# Escritorio bspwm (X11) con SDDM como pantalla de inicio de sesión. Lo de
# dentro de la sesión (bspwm, polybar, rofi...) es de Home Manager:
# modules/home/escritorio.nix.

{ config, pkgs, ... }:

let
  # Tema oficial de Catppuccin para SDDM, con el fondo y la fuente de Stylix.
  temaLogin = pkgs.catppuccin-sddm.override {
    flavor = "macchiato";
    accent = "mauve";
    font = config.stylix.fonts.sansSerif.name;
    fontSize = "11";
    background = "${config.stylix.image}";
    loginBackground = true; # panel detrás del formulario: se lee mejor sobre el fondo
  };
in
{
  services.xserver.enable = true;

  # Pantalla de inicio de sesión. No se reinicia con switch: se ve al reiniciar.
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm; # Qt 6, el que pide el tema
    theme = "catppuccin-macchiato-mauve";
    settings.Theme = {
      CursorTheme = config.stylix.cursor.name;
      CursorSize = config.stylix.cursor.size;
    };
  };
  environment.systemPackages = [
    temaLogin
    config.stylix.cursor.package # para que SDDM encuentre el cursor
  ];

  services.displayManager.defaultSession = "bspwm";
  # La sesión ejecuta el script de Home Manager (modules/home/escritorio.nix),
  # que arranca bspwm y los servicios solo de bspwm (polybar, picom...).
  services.xserver.displayManager.session = [
    {
      manage = "desktop";
      name = "bspwm";
      start = "exec $HOME/.hm-xsession";
    }
  ];
  # Llavero de GNOME, desbloqueado al iniciar sesión (ahí guarda gh su token).
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  # Bloqueo de pantalla de bspwm (Super+Shift+X); el módulo le da acceso a PAM.
  programs.i3lock.enable = true;

  # Teclado español. Sin variante "nodeadkeys": así ´ + a = á (teclas muertas).
  services.xserver.xkb = {
    layout = "es";
    variant = "";
  };

  # Scroll natural (como en Mac). El de GNOME va por dconf (gnome.nix).
  services.libinput = {
    mouse.naturalScrolling = true;
    touchpad.naturalScrolling = true;
  };
}
