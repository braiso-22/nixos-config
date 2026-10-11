# Escritorio bspwm (X11) con LightDM. Lo de dentro de la sesión (bspwm,
# polybar, rofi...) es de Home Manager: modules/home/escritorio.nix.

{
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
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
  # Desbloquear el llavero de GNOME al iniciar sesión (ahí guarda gh su token).
  security.pam.services.lightdm.enableGnomeKeyring = true;
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
