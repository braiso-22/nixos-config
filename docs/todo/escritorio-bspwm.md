# Fase 4: escritorio con bspwm

- **Estado:** pendiente
- **Fecha:** —
- **Commit / tag:** —

## Contexto
Se quiere un escritorio más bonito y productivo que GNOME por defecto, con
gestor de ventanas en mosaico (tiling) manejado por teclado: **bspwm + sxhkd**.

Problema: el sistema trae **GNOME 50, que solo funciona con Wayland**, y bspwm
es de **X11**. Es muy probable que GDM 50 ya no pueda arrancar sesiones X11.

## Decisiones
- **bspwm + LightDM** (elegido frente a Sway o Hyprland). Hyprland necesita
  aceleración gráfica y suele ir mal en una VM QEMU sobre Mac; bspwm sobre X11
  va bien en VMs.
- Cambiar GDM por **LightDM**. **GNOME se mantiene** como sesión alternativa
  por si algo falla (comprobar que GNOME Wayland arranca desde LightDM).
- Configuración con los módulos de Home Manager: `xsession.windowManager.bspwm`
  y `services.sxhkd`.

## Plan
- [ ] LightDM + sesión bspwm en `configuration.nix`; GNOME como alternativa
- [ ] bspwm + sxhkd (atajos: terminal, lanzador, cerrar, mover/redimensionar,
      escritorios)
- [ ] Terminal para bspwm (alacritty o kitty; ghostty necesita OpenGL, revisar en la VM)
- [ ] polybar (barra), rofi (lanzador), picom (sombras/transparencias; vigilar
      rendimiento en la VM), dunst (notificaciones), fondo de pantalla (feh)
- [ ] **Stylix**: un único tema (Catppuccin, Tokyo Night…) para terminal,
      barra, rofi, VS Code, GTK, bat…
- [ ] `spice-vdagent` en la sesión de bspwm (GNOME lo arranca solo; en bspwm
      no): portapapeles compartido con el Mac y resolución automática
- [ ] Teclado `es` y scroll natural en X11 (fuera de GNOME, dconf no aplica:
      usar `services.libinput` / xkb). Reiniciar la VM tras cambiarlo.
- [ ] Capturas de pantalla (flameshot) y bloqueo de pantalla

## Resultado
