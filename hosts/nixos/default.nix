# La VM de brais: QEMU aarch64 en UTM (Mac). Solo lo propio de esta máquina;
# lo común está en modules/nixos.

{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix # generado por nixos-generate-config: no editar
  ];

  networking.hostName = "nixos";

  # GNOME (Wayland) se mantiene como sesión alternativa a bspwm en la VM
  # (se elige en el icono de sesiones de LightDM). Los portátiles no lo llevan.
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

  programs.nix-ld.enable = true;

  # Invitado de QEMU/UTM: portapapeles y resolución con el Mac (SPICE).
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  # Versión de NixOS con la que se instaló esta máquina. No se cambia nunca,
  # ni al actualizar (protege datos de servicios creados con versiones viejas).
  system.stateVersion = "26.05";
}
