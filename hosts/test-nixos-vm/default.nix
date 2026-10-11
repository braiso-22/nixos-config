# test-nixos-vm: la VM de pruebas de brais, QEMU aarch64 en UTM (Mac).
# Solo lo propio de esta máquina; lo común está en modules/nixos.

{
  imports = [
    ./hardware-configuration.nix # generado por nixos-generate-config: no editar
  ];

  networking.hostName = "test-nixos-vm";

  empresa = {
    vm.enable = true; # invitado QEMU/UTM (modules/nixos/vm.nix)
    gnome.enable = true; # GNOME de reserva (modules/nixos/gnome.nix)
  };

  programs.nix-ld.enable = true;

  # Versión de NixOS con la que se instaló esta máquina. No se cambia nunca,
  # ni al actualizar (protege datos de servicios creados con versiones viejas).
  system.stateVersion = "26.05";
}
