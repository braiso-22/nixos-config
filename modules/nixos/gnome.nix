# empresa.gnome.enable: GNOME (Wayland) como sesión de reserva junto a bspwm.
# Se elige en el engranaje de la pantalla de login (SDDM).

{ config, lib, ... }:

{
  options.empresa.gnome.enable = lib.mkEnableOption "GNOME como sesión de reserva";

  config = lib.mkIf config.empresa.gnome.enable {
    services.desktopManager.gnome.enable = true;

    # Ajustes por defecto de GNOME (dconf) para todos los usuarios
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          # Scroll natural (como en Mac). En la VM el trackpad llega como ratón,
          # así que se activa en ambos.
          "org/gnome/desktop/peripherals/mouse".natural-scroll = true;
          "org/gnome/desktop/peripherals/touchpad".natural-scroll = true;
          # Distribución de teclado de GNOME: español con teclas muertas
          "org/gnome/desktop/input-sources".sources = [
            (lib.gvariant.mkTuple [
              "xkb"
              "es"
            ])
          ];
        };
      }
    ];
  };
}
