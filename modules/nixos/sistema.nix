# Base del sistema común a todos los equipos: arranque, red, idioma, teclado,
# sonido, impresión y Nix. Opciones: https://search.nixos.org/options

{ pkgs, ... }:

{
  # Arranque EFI con systemd-boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10; # generaciones en el menú de arranque
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Madrid";

  i18n.defaultLocale = "es_ES.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  console.keyMap = "es"; # teclado de la consola de texto; el de X11 en escritorio.nix

  services.printing.enable = true; # CUPS

  # Sonido con PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Limpieza automática (el disco de la VM es pequeño). Si el equipo está
  # apagado a la hora programada, se ejecuta al arrancar.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    # Generaciones de más de 14 días: se pueden recuperar durante 2 semanas.
    options = "--delete-older-than 14d";
  };
  # Deduplica la tienda de Nix: archivos idénticos ocupan una sola vez.
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
