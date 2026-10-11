# Tema común con Stylix (módulo de NixOS; se aplica también a Home Manager).
# Colores Catppuccin Mocha, fuentes y fondo para terminal, GTK, VS Code, bat,
# fzf, btop, rofi, dunst, bspwm, LightDM, GNOME…
# Lo que Stylix no cubre (polybar) usa config.lib.stylix.colors en modules/home/escritorio.nix.

{ pkgs, ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # Fondo oficial de NixOS en Catppuccin Mocha (viene en nixpkgs).
    image = "${pkgs.nixos-artwork.wallpapers.catppuccin-mocha}/share/backgrounds/nixos/nixos-wallpaper-catppuccin-mocha.png";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      # La fuente de interfaz de GNOME, para que GNOME siga viéndose igual.
      sansSerif = {
        package = pkgs.adwaita-fonts;
        name = "Adwaita Sans";
      };
      serif = {
        package = pkgs.adwaita-fonts;
        name = "Adwaita Sans";
      };
      sizes.terminal = 11; # terminal; VS Code lo convierte a ~14,7 px
    };

    # En bspwm, sin esto se ve el cursor "X" de X11 sobre el escritorio.
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    opacity.terminal = 0.92; # algo de transparencia en Alacritty (picom)

    # Estos objetivos modifican paquetes y obligan a recompilarlos sin caché
    # (GNOME Shell, GDM, gtksourceview → Papers en Rust...): ~1 GiB más de
    # descarga y mucho tiempo de compilación solo para tematizar GNOME, que es
    # la sesión de reserva. GNOME queda con su aspecto normal.
    targets = {
      gnome.enable = false;
      gtksourceview.enable = false;
      nixos-icons.enable = false;
    };
  };
}
