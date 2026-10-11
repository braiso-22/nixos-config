# Pantalla de inicio de sesión: SDDM con Catppuccin Macchiato

- **Estado:** implementado
- **Fecha:** 2026-10-11 (inicio) → 2026-10-11 (fin)
- **Commit / tag:** ver tag 0.12.0

## Contexto
La pantalla de login (LightDM con `lightdm-gtk-greeter`) se ve anticuada y en
modo claro: Stylix solo le pone el fondo; el resto es Adwaita claro con cursor
de 16 px. Se valoró:
- LightDM con tema oscuro (`adw-gtk3-dark` + Bibata): 0 MiB, pero la misma
  pantalla de siempre, solo que oscura.
- Slick greeter: parecido al anterior.
- **SDDM con el tema oficial de Catppuccin**: moderno (reloj grande, campos
  redondeados, selector de sesión), 3,9 MiB (las librerías Qt ya están). Elegido.

## Decisiones
- **Variante Macchiato** (acento mauve, el de por defecto), elegida por el
  usuario aunque el escritorio es Mocha: es algo más clara y queda bien con él.
- Fondo: el mismo del escritorio (`config.stylix.image`), con
  `loginBackground` (panel detrás del formulario para que se lea bien).
- Fuente: la de interfaz de Stylix (Adwaita Sans, ya instalada en el sistema);
  cursor: el de Stylix (Bibata, 24 px), añadido al sistema para que SDDM lo vea.
- SDDM de Qt 6 (`kdePackages.sddm`), que es el que pide el tema, sobre X11 (la
  sesión bspwm es X11).
- La sesión bspwm (`services.xserver.displayManager.session`) y la sesión por
  defecto (`services.displayManager.defaultSession`) sirven igual con SDDM.
- El llavero de GNOME (donde `gh` guarda el token) se desbloquea al entrar:
  `security.pam.services.sddm.enableGnomeKeyring` en vez del de lightdm, y
  `services.gnome.gnome-keyring.enable` explícito (hoy lo activa GNOME; en los
  portátiles sin GNOME haría falta igual).
- Va en `modules/nixos/escritorio.nix`: es lo común de todos los equipos.
- **Riesgo**: el gestor de pantalla no se reinicia con `switch`; se ve tras
  reiniciar. Si SDDM fallara, en el menú de arranque (systemd-boot) se elige
  la generación anterior, que tiene LightDM.

## Plan
- [x] Cambiar LightDM por SDDM en `modules/nixos/escritorio.nix`
- [x] `dry-build` y tamaño de descarga
- [x] Aplicar, reiniciar y probar: entrar en bspwm, `gh auth status` (llavero),
      que GNOME siga en el selector de sesión
- [x] Actualizar `CLAUDE.md` (menciones a LightDM)

## Resultado
`dry-build`: 8,1 MiB de descarga. Antes de aplicar se construyó el sistema
(`nix build ...toplevel`, sin activarlo) y se abrió el login en modo de prueba
(`sddm-greeter-qt6 --test-mode --theme ...`) dentro de la sesión: el tema sale
bien (Macchiato, Adwaita Sans 11, fondo de NixOS, reloj, botones de apagar,
reiniciar y suspender, y menú de sesión en el engranaje).

Aplicado con `rebuild` y reinicio: la sesión la abre SDDM (bspwm, X11), el
llavero se desbloquea al entrar (`gh auth status`: conectado, token en el
llavero), SDDM ofrece las mismas sesiones que LightDM (bspwm y GNOME) y no hay
servicios fallidos.
