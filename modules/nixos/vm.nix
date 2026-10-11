# empresa.vm.enable: el equipo es una máquina virtual QEMU/UTM (en un Mac).
# Activa las herramientas de invitado: portapapeles compartido y ajuste de
# resolución con el anfitrión (SPICE).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.empresa.vm.enable = lib.mkEnableOption "las herramientas de invitado de QEMU/UTM";

  config = lib.mkIf config.empresa.vm.enable {
    services.spice-vdagentd.enable = true;
    services.qemuGuest.enable = true;

    # En GNOME el agente de SPICE lo arranca GNOME; en bspwm hay que hacerlo a
    # mano al entrar en la sesión (para todos los usuarios del equipo).
    home-manager.sharedModules = [
      { xsession.initExtra = "${pkgs.spice-vdagent}/bin/spice-vdagent"; }
    ];
  };
}
