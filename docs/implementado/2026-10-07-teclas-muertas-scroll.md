# Teclas muertas y scroll natural

- **Estado:** implementado
- **Fecha:** 2026-10-07
- **Commit / tag:** 838b64a / 0.2.0

## Contexto
No se podían escribir tildes (´ + a = á) y el scroll iba al revés que en el Mac.

## Decisiones
- Teclado `es` **sin** variante `nodeadkeys` en `services.xserver.xkb`, y la
  misma distribución en GNOME vía dconf (`org/gnome/desktop/input-sources`).
- Scroll natural vía `programs.dconf.profiles.user.databases`, en `mouse` y en
  `touchpad`: el trackpad del Mac llega a la VM como "QEMU USB Tablet/Mouse",
  no como touchpad.

## Resultado
Funciona, pero **solo tras reiniciar la VM**: después del `switch`, `gsettings`
ya mostraba los valores buenos y aun así no se aplicaban. Para futuros cambios
de teclado o ratón: reiniciar antes de investigar nada más.
