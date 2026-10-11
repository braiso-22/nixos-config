# Comando info-portatil: recoge en ~/info-portatil.txt lo necesario para
# configurar el portátil (modelo, gráficas, Wi-Fi, batería, monitores y el
# hardware-configuration.nix). No incluye números de serie.

{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "info-portatil";
      runtimeInputs = with pkgs; [
        pciutils # lspci
        usbutils # lsusb
        xrandr
        networkmanager # nmcli
        coreutils
        gnugrep
      ];
      text = ''
        salida="$HOME/info-portatil.txt"
        seccion() { printf '\n===== %s =====\n' "$1"; }
        {
          seccion "Modelo"
          for f in sys_vendor product_name product_family board_name bios_version bios_date; do
            printf '%s: %s\n' "$f" "$(cat /sys/class/dmi/id/$f 2>/dev/null || echo '?')"
          done
          seccion "Procesador"
          grep -m1 'model name' /proc/cpuinfo || true
          seccion "Kernel"
          uname -r
          seccion "Gráficas (lspci, con controlador en uso)"
          lspci -nnk | grep -A3 -Ei 'vga|3d|display' || true
          seccion "Red (Wi-Fi, Ethernet, Bluetooth)"
          lspci -nnk | grep -A3 -Ei 'network|ethernet|wireless' || true
          lsusb | grep -Ei 'bluetooth|wireless|wlan|802\.11' || true
          nmcli device status || true
          seccion "Batería y cargador"
          ls /sys/class/power_supply/ || true
          for b in /sys/class/power_supply/BAT*; do
            [ -e "$b" ] || continue
            printf '%s: %s %s%%, capacidad %s de %s\n' "$b" "$(cat "$b/status")" "$(cat "$b/capacity")" \
              "$(cat "$b/energy_full" 2>/dev/null || cat "$b/charge_full" 2>/dev/null)" \
              "$(cat "$b/energy_full_design" 2>/dev/null || cat "$b/charge_full_design" 2>/dev/null)"
          done
          seccion "Brillo"
          ls /sys/class/backlight/ || true
          seccion "Monitores (xrandr)"
          xrandr --query 2>/dev/null || echo "(sin sesión gráfica)"
          seccion "Todo el PCI"
          lspci -nn
          seccion "Todo el USB"
          lsusb
          seccion "Errores del arranque"
          sudo journalctl -b -p err --no-pager | tail -n 60 || true
          seccion "hardware-configuration.nix"
          sudo nixos-generate-config --show-hardware-config
        } >"$salida" 2>&1

        echo "Informe guardado en $salida"
        echo
        echo "Para pasármelo (gist secreto: solo lo ve quien tenga el enlace):"
        echo "  gh auth login --insecure-storage   # GitHub.com, HTTPS, 'Login with a web browser'"
        echo "  gh gist create --secret --desc info-portatil $salida"
      '';
    })
  ];
}
