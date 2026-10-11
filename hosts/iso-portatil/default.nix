# iso-portatil: sistema "live" que arranca desde un USB en un portátil x86_64,
# sin instalar nada, para probar el hardware (Wi-Fi, batería, gráficas...).
# Se construye en GitHub Actions (.github/workflows/iso-portatil.yml).
# Es pública: no debe llevar secretos.

{ lib, modulesPath, ... }:

{
  imports = [
    # Módulo oficial de las ISOs de instalación de NixOS (imagen arrancable y
    # herramientas como nixos-generate-config).
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    ./info-portatil.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "iso-portatil";

  # Todo el firmware (Wi-Fi, Bluetooth, gráficas...): aún no sabemos qué chips lleva.
  hardware.enableAllFirmware = true;

  # Entra solo en bspwm. La contraseña es pública y solo vale en el USB (la
  # pide el bloqueo de pantalla). sudo no pide contraseña (lo pone la ISO).
  services.displayManager.autoLogin = {
    enable = true;
    user = "brais";
  };
  users.users.brais.initialPassword = "prueba";

  # Sin ZFS (la ISO oficial lo trae; no lo usamos y ocupa).
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # Docker no hace falta para probar el hardware y en el USB no funcionaría.
  virtualisation.docker.rootless.enable = lib.mkForce false;

  # Compresión rápida: la ISO ocupa algo más pero GitHub la construye antes.
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  system.stateVersion = "26.05";
}
