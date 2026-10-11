# Fase 4: escritorio con bspwm

- **Estado:** implementado
- **Fecha:** 2026-10-09 → 2026-10-11
- **Commit / tag:** ver tag 0.7.0

## Contexto
Se quiere un escritorio más bonito y productivo que GNOME por defecto, con
gestor de ventanas en mosaico (tiling) manejado por teclado: **bspwm + sxhkd**.
GNOME se mantiene como sesión alternativa.

Datos de la VM que condicionan las decisiones (comprobados 2026-10-09):
- **Sin aceleración gráfica 3D** (`virtio_gpu`, `-virgl`): todo se dibuja por
  CPU (llvmpipe). Los efectos pesados (desenfoque) irán a tirones.
- Pantalla `Virtual-1` a **1280×800, escala 1** (sin HiDPI).
- GNOME 50 es solo Wayland; bspwm es X11. `services.xserver.enable` está a
  `false` hoy.
- El GDM 50 de nixpkgs **sí puede** arrancar sesiones X11 (`gdm-x-session`,
  `-Dgdm-xsession=true`), contra lo que se suponía al planear. Aun así el
  usuario eligió LightDM.
- Disco: 48 GB, ~23 GB libres.

## Decisiones
- **LightDM** en lugar de GDM (elección del usuario; GDM habría servido).
  En LightDM se elige la sesión: bspwm o GNOME (alternativa si algo falla).
- **Tema Catppuccin Mocha con Stylix** (`github:nix-community/stylix`, rama
  `release-26.05`, con `follows` a nixpkgs): un esquema base16 para terminal,
  GTK, VS Code, bat, fzf, btop, rofi, dunst, LightDM… Fuente monoespaciada:
  JetBrainsMono Nerd Font (ya instalada). Lo que Stylix no cubra (polybar) usa
  sus colores (`config.lib.stylix.colors`).
- **Stylix sin los objetivos `gnome`, `gtksourceview` y `nixos-icons`**: modifican
  paquetes y obligan a recompilarlos sin caché (GNOME Shell, GDM,
  gtksourceview → Papers en Rust, que arrastra el compilador de Rust): con
  ellos, 1,2 GiB de descarga y 176 compilaciones; sin ellos, 202 MiB y solo
  archivos de configuración. GNOME (sesión de reserva) queda con su aspecto
  normal salvo fondo, fuentes y apps GTK.
- Conflictos resueltos con Stylix: la fuente de GNOME Console (`dconf` en
  `home.nix`) y `editor.fontFamily`/`editor.fontSize` de `vscode.nix` los pone
  ahora Stylix (VS Code: `stylix.targets.vscode.profileNames`). Qt (flameshot)
  con `stylix.targets.qt.platform = "qtct"` (GNOME pasaba `gnome`, no
  soportado). Fuente de interfaz: Adwaita Sans (la de GNOME); tamaño de
  terminal 11; cursor Bibata (sin él, en bspwm se ve la "X" de X11).
- **Aplicar con `nixos-rebuild boot` + reiniciar**, no `switch`: el cambio de
  GDM a LightDM reinicia el gestor de sesión y cerraría la sesión de GNOME en
  marcha (con la terminal y Claude dentro). Si algo falla al arrancar: en el
  menú de arranque, la generación anterior.
- **Fondo**: el oficial de NixOS en Catppuccin Mocha de nixpkgs
  (`nixos-artwork.wallpapers.catppuccin-mocha`), sin descargar imágenes de fuera.
- **Terminal Alacritty** (rápida y simple; las ventanas las organiza bspwm).
- **Efectos ligeros con picom**: backend `xrender` (no GL: no hay GPU),
  sombras suaves, transición al abrir/cerrar, algo de transparencia en la
  terminal. **Sin desenfoque** ni esquinas redondeadas.
- **Modificador de atajos: Super (Cmd ⌘ en el Mac)**, a probar con la captura
  de teclado de UTM. Si resulta incómodo, se cambia a Alt (una variable).
- Configuración en un módulo nuevo **`escritorio.nix`** (Home Manager),
  importado desde `home.nix`; lo del sistema (X11, LightDM, sesión, i3lock)
  en `configuration.nix`.
- **Arranque de la sesión** con el método del manual de Home Manager: sesión
  de LightDM que ejecuta `~/.hm-xsession` (`xsession.scriptPath`). Así se
  activa `hm-graphical-session.target` y arrancan los servicios de usuario
  (sxhkd, polybar, picom, dunst).
- Esos servicios se atan a `hm-graphical-session.target` y **no** a
  `graphical-session.target`: si no, también arrancarían en la sesión de GNOME
  (dunst chocaría con las notificaciones de GNOME, polybar saldría encima…).
- **Atajos** (sxhkd), con Super:
  - Super+Enter terminal · Super+D lanzador (rofi) · Super+Q cerrar ventana
  - Super+1…9 escritorio · Super+Shift+1…9 mover ventana a escritorio
  - Super+H/J/K/L o flechas: foco · con Shift: intercambiar ventanas
  - Super+F pantalla completa · Super+T mosaico · Super+S flotante
  - Super+Alt+R reiniciar bspwm · Super+Escape recargar atajos
  - Super+Alt+Q cerrar sesión · Super+Shift+X bloquear pantalla
  - Impr Pant: captura (flameshot)
- **Chuleta de atajos (Cmd+I)**, pedida al probar: los atajos se definen una
  sola vez en `escritorio.nix` (tecla, acción, texto visible y descripción) y de
  esa lista salen `services.sxhkd.keybindings` y la chuleta, que se muestra en
  rofi (se puede filtrar escribiendo). Así nunca se desincronizan. Tecla `i`:
  `/` necesita Shift en el teclado español y F1 necesita fn en el Mac.
- **Pantalla Retina**: al poner UTM a pantalla completa la VM pasó a 3024×1898
  y todo se veía diminuto (bspwm no escala). Se desactivó el **Retina Mode de
  UTM** (la VM recibe la resolución en puntos, ~1512×949) en vez de escalar ×2:
  sin GPU, Retina obliga a la CPU a dibujar 4 veces más píxeles.
- **Cmd+Q, Cmd+H, Cmd+W… los captura macOS** si UTM no tiene capturado el
  teclado. Solución elegida: capturar (pantalla completa con captura
  automática); alternativa si molesta: mover esos atajos a teclas libres.
- **Barra polybar**: escritorios de bspwm, título de ventana, CPU, memoria,
  disco, volumen y fecha/hora.
- **Notificaciones dunst**, **capturas flameshot**, **bloqueo i3lock** (con
  `programs.i3lock` de NixOS para que tenga PAM) vía `services.screen-locker`.
- **Fuera de GNOME, dconf no aplica**: teclado `es` ya está en xkb; scroll
  natural con `services.libinput.mouse/touchpad.naturalScrolling`.
- **`spice-vdagent`** se arranca en la sesión (GNOME lo hace solo; bspwm no):
  portapapeles compartido con el Mac y, si funciona, resolución automática.

## Plan
- [x] Input Stylix + tema Catppuccin Mocha (`tema.nix`; conflictos resueltos)
- [x] `configuration.nix`: X11, LightDM, sesión `~/.hm-xsession`, i3lock,
      scroll natural en X11
- [x] `escritorio.nix`: bspwm, sxhkd, polybar, rofi, picom, dunst, alacritty,
      flameshot, screen-locker, fondo, spice-vdagent
- [x] `dry-build`: 202 MiB de descarga (ver Stylix arriba)
- [x] Aplicar con `sudo nixos-rebuild boot` y **reiniciar la VM** (cambia el
      gestor de inicio de sesión; los cambios de teclado/ratón piden reinicio).
      Arrancó bien con LightDM, pero **entró en GNOME**: sin
      `services.displayManager.defaultSession`, LightDM cogió GNOME. Se elige
      bspwm en el icono de sesiones del greeter (lo recuerda). Pendiente:
      `defaultSession = "bspwm"` en la configuración
- [x] Probar: entrar en bspwm, atajos, barra, lanzador, terminal, captura,
      bloqueo, portapapeles, resolución; y que GNOME sigue funcionando
- [x] Ajustes según lo que no guste; cerrar la fase (tag)

## Resultado
### Resumen
- Sesión **bspwm** (por defecto) y **GNOME** (reserva) en **LightDM**.
- Tema **Catppuccin Mocha** con Stylix (`tema.nix`) en terminal, GTK, VS Code,
  bat, fzf, btop, rofi, dunst, LightDM; polybar con sus colores.
- `escritorio.nix`: bspwm, sxhkd (atajos en una lista única con chuleta en
  **Cmd+I**), polybar, rofi, picom ligero, dunst, alacritty, flameshot,
  bloqueo con i3lock, spice-vdagent.
- Probado por el usuario: lanzador, terminal, atajos, chuleta, resolución
  automática (con Retina desactivado en UTM), portapapeles, scroll, bloqueo,
  captura: "todo bien".
- Descarga total: ~202 MiB (tras quitar los objetivos de Stylix que
  recompilaban GNOME).

### Problemas encontrados al probar (2026-10-11)
- **Restos del menú de rofi al cerrarlo sin elegir nada.** Dos causas:
  - **Dos picom**: Home Manager arranca el autoarranque XDG
    (`xdg-desktop-autostart.target`) en la sesión, y el paquete picom trae
    `picom.desktop` (sin `OnlyShowIn`: también arrancaría en GNOME). Lanzaba
    un picom antes que el servicio, que fallaba en bucle ("Another composite
    manager is already running", 62 reinicios). Arreglo: ocultarlo con
    `~/.config/autostart/picom.desktop` (`Hidden=true`).
  - picom solo redibujaba lo "dañado" (`use-damage`), que en la VM sin GPU deja
    restos. Arreglo: `use-damage = false` (redibuja la pantalla entera).
- **Cmd+I daba "error while parsing theme"**: en los comandos de sxhkd las
  llaves `{…}` son sintaxis propia (`{1-9}`, `{h,j,k,l}`) y se comían las del
  `-theme-str` de rofi. Arreglo: el comando va en un script
  (`pkgs.writeShellScript "ver-atajos"`) y sxhkd solo llama al script.
- **Entró en GNOME tras reiniciar**: `services.displayManager.defaultSession =
  "bspwm"`.
- Nota: `display-manager.service` tiene `restartIfChanged = false`, así que un
  `switch` no reinicia LightDM ni cierra la sesión; el `boot` + reinicio inicial
  era precavido de más (aunque el cambio de GDM a LightDM igual necesitaba
  reiniciar para verse).
