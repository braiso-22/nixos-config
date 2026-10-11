# Escritorio bspwm (lo importa modules/home). La sesión "bspwm" de LightDM
# ejecuta ~/.hm-xsession, que arranca todo esto. Colores y fuentes:
# modules/nixos/tema.nix.
#
# Atajos: lista `atajos` más abajo; en el escritorio, mod+I (Cmd+I) los muestra.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Tecla de los atajos. Para usar Alt (Option ⌥) en vez de Cmd: "alt".
  mod = "super";

  c = config.lib.stylix.colors.withHashtag; # colores del tema (base00…base0F)
  fuente = config.stylix.fonts.monospace.name;

  # Atajos: se definen una sola vez. De esta lista salen la configuración de
  # sxhkd y la chuleta que se abre con mod+I.
  #   tecla: sintaxis de sxhkd · accion: comando · ver/desc: lo que muestra la chuleta
  modVer = if mod == "super" then "Cmd" else "Alt";
  atajos = [
    {
      tecla = "${mod} + i";
      accion = "${verChuleta}"; # script: sxhkd se come las llaves {} del tema de rofi
      ver = "${modVer}+I";
      desc = "Esta chuleta de atajos (escribe para filtrar)";
    }
    {
      tecla = "${mod} + Return";
      accion = "alacritty";
      ver = "${modVer}+Enter";
      desc = "Abrir una terminal";
    }
    {
      tecla = "${mod} + d";
      accion = "rofi -show drun";
      ver = "${modVer}+D";
      desc = "Lanzador de aplicaciones";
    }
    {
      tecla = "${mod} + q";
      accion = "bspc node -c";
      ver = "${modVer}+Q";
      desc = "Cerrar la ventana activa";
    }
    {
      tecla = "${mod} + f";
      accion = "bspc node -t ~fullscreen";
      ver = "${modVer}+F";
      desc = "Pantalla completa (otra vez para salir)";
    }
    {
      tecla = "${mod} + s";
      accion = "bspc node -t ~floating";
      ver = "${modVer}+S";
      desc = "Ventana flotante (otra vez para volver)";
    }
    {
      tecla = "${mod} + t";
      accion = "bspc node -t tiled";
      ver = "${modVer}+T";
      desc = "Volver al mosaico";
    }
    {
      tecla = "${mod} + {h,j,k,l}";
      accion = "bspc node -f {west,south,north,east}";
      ver = "${modVer}+H/J/K/L";
      desc = "Ir a la ventana de la izquierda/abajo/arriba/derecha";
    }
    {
      tecla = "${mod} + {Left,Down,Up,Right}";
      accion = "bspc node -f {west,south,north,east}";
      ver = "${modVer}+flechas";
      desc = "Ir a la ventana en esa dirección";
    }
    {
      tecla = "${mod} + shift + {h,j,k,l}";
      accion = "bspc node -s {west,south,north,east}";
      ver = "${modVer}+Shift+H/J/K/L";
      desc = "Intercambiar la ventana con la de esa dirección";
    }
    {
      tecla = "${mod} + shift + {Left,Down,Up,Right}";
      accion = "bspc node -s {west,south,north,east}";
      ver = "${modVer}+Shift+flechas";
      desc = "Intercambiar la ventana con la de esa dirección";
    }
    {
      tecla = "${mod} + ctrl + {h,j,k,l}";
      accion = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
      ver = "${modVer}+Ctrl+H/J/K/L";
      desc = "Agrandar la ventana hacia esa dirección";
    }
    {
      tecla = "${mod} + {1-9}";
      accion = "bspc desktop -f '^{1-9}'";
      ver = "${modVer}+1-9";
      desc = "Ir al escritorio 1…9";
    }
    {
      tecla = "${mod} + shift + {1-9}";
      accion = "bspc node -d '^{1-9}'";
      ver = "${modVer}+Shift+1-9";
      desc = "Mandar la ventana al escritorio 1…9";
    }
    {
      tecla = "${mod} + shift + s";
      accion = "flameshot gui";
      ver = "${modVer}+Shift+S";
      desc = "Captura de pantalla (se guarda en ~/Imágenes)";
    }
    {
      tecla = "Print";
      accion = "flameshot gui";
      ver = "Impr Pant";
      desc = "Captura de pantalla (teclados con esa tecla)";
    }
    {
      tecla = "${mod} + shift + x";
      accion = "loginctl lock-session"; # lo atiende screen-locker
      ver = "${modVer}+Shift+X";
      desc = "Bloquear la pantalla";
    }
    {
      tecla = "${mod} + Escape";
      accion = "pkill -USR1 -x sxhkd";
      ver = "${modVer}+Esc";
      desc = "Recargar los atajos";
    }
    {
      tecla = "${mod} + alt + r";
      accion = "bspc wm -r";
      ver = "${modVer}+Alt+R";
      desc = "Reiniciar bspwm (sin cerrar ventanas)";
    }
    {
      tecla = "${mod} + alt + q";
      accion = "bspc quit";
      ver = "${modVer}+Alt+Q";
      desc = "Cerrar sesión";
    }
  ];

  # Texto de la chuleta: la tecla alineada a la izquierda y la descripción.
  # (`ver` solo en ASCII: stringLength cuenta bytes y "…" descuadraría.)
  ancho = 1 + lib.foldl' lib.max 0 (map (a: lib.stringLength a.ver) atajos);
  rellenar = s: s + lib.concatStrings (lib.replicate (ancho - lib.stringLength s) " ");
  verChuleta = pkgs.writeShellScript "ver-atajos" ''
    rofi -dmenu -i -no-custom -p Atajos -theme-str 'window {width: 45%;}' < ${chuleta}
  '';
  chuleta = pkgs.writeText "atajos.txt" (
    lib.concatMapStringsSep "\n" (a: "${rellenar a.ver} ${a.desc}") atajos
  );
in
{
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession"; # lo ejecuta la sesión de modules/nixos/escritorio.nix
    # Portapapeles compartido con el Mac y ajuste de resolución (en GNOME lo
    # arranca GNOME; en bspwm hay que hacerlo a mano).
    initExtra = "${pkgs.spice-vdagent}/bin/spice-vdagent";

    windowManager.bspwm = {
      enable = true;
      monitors.focused = map toString (lib.range 1 9); # escritorios 1…9
      settings = {
        border_width = 2;
        window_gap = 8;
        split_ratio = 0.52;
        borderless_monocle = true;
        gapless_monocle = true;
        focus_follows_pointer = true;
      };
      rules."flameshot".state = "floating";
    };
  };

  services.sxhkd = {
    enable = true;
    keybindings = lib.listToAttrs (map (a: lib.nameValuePair a.tecla a.accion) atajos);
  };

  programs.alacritty = {
    enable = true;
    settings.window.padding = {
      x = 8;
      y = 6;
    };
  };

  programs.rofi = {
    enable = true;
    terminal = "alacritty";
    extraConfig = {
      show-icons = true;
      display-drun = "Aplicaciones";
    };
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybarFull; # incluye el módulo de volumen (pulseaudio)
    script = "polybar main &";
    settings = {
      "bar/main" = {
        width = "100%";
        height = 26;
        background = c.base00;
        foreground = c.base05;
        font-0 = "${fuente}:size=10;2";
        locale = "es_ES.UTF-8";
        modules-left = "bspwm";
        modules-center = "xwindow";
        modules-right = "cpu memory filesystem pulseaudio date";
        module-margin = 1;
        padding-right = 1;
        separator = "|";
        separator-foreground = c.base03;
        wm-restack = "bspwm";
      };
      "module/bspwm" = {
        type = "internal/bspwm";
        label-focused = "%name%";
        label-focused-background = c.base02;
        label-focused-foreground = c.base0D;
        label-focused-padding = 1;
        label-occupied = "%name%";
        label-occupied-padding = 1;
        label-urgent = "%name%";
        label-urgent-foreground = c.base08;
        label-urgent-padding = 1;
        label-empty = "%name%";
        label-empty-foreground = c.base03;
        label-empty-padding = 1;
      };
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:…%";
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        label = "CPU %percentage%%";
      };
      "module/memory" = {
        type = "internal/memory";
        interval = 3;
        label = "RAM %percentage_used%%";
      };
      "module/filesystem" = {
        type = "internal/fs";
        mount-0 = "/";
        interval = 60;
        label-mounted = "Disco %free%";
      };
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        label-volume = "Vol %percentage%%";
        label-muted = "Silencio";
        label-muted-foreground = c.base03;
      };
      "module/date" = {
        type = "internal/date";
        interval = 5;
        date = "%a %d %b";
        time = "%H:%M";
        label = "%date%  %time%";
        label-foreground = c.base0D;
      };
    };
  };

  # Efectos ligeros: la VM no tiene GPU, así que backend xrender (CPU) y sin
  # desenfoque.
  services.picom = {
    enable = true;
    backend = "xrender";
    vSync = false;
    shadow = true;
    shadowOpacity = 0.35;
    shadowExclude = [ "class_g = 'Polybar'" ];
    fade = true;
    fadeDelta = 4;
    settings = {
      shadow-radius = 12;
      # Redibujar la pantalla entera cuando algo cambia, no solo "lo dañado":
      # sin GPU, en la VM quedaban restos del menú de rofi al cerrarlo.
      use-damage = false;
    };
  };
  # El paquete picom trae un autoarranque XDG (picom.desktop) que lanzaba un
  # segundo picom antes que el servicio (y también lo haría en GNOME): se oculta.
  xdg.configFile."autostart/picom.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=picom
    Hidden=true
  '';

  services.dunst.enable = true; # notificaciones

  # Stylix solo sabe dar tema a Qt (flameshot) con qtct.
  stylix.targets.qt.platform = "qtct";

  services.flameshot = {
    enable = true;
    settings.General = {
      savePath = "${config.home.homeDirectory}/Imágenes";
      disabledTrayIcon = true; # la barra no tiene bandeja
      showStartupLaunchMessage = false;
    };
  };

  # Bloqueo: a los 15 min sin actividad o con mod+Shift+X.
  services.screen-locker = {
    enable = true;
    inactiveInterval = 15;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c ${config.lib.stylix.colors.base00}";
  };

  # Estos servicios irían a graphical-session.target, que también usa GNOME:
  # se atan a la sesión de bspwm para que no arranquen en GNOME.
  systemd.user.services =
    lib.genAttrs
      [
        "picom"
        "flameshot"
        "xss-lock"
        "xautolock-session"
      ]
      (_: {
        Unit.PartOf = lib.mkForce [ "hm-graphical-session.target" ];
        Install.WantedBy = lib.mkForce [ "hm-graphical-session.target" ];
      });
}
