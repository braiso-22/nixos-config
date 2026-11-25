# Reinstalar la VM desde cero

Guía para volver a crear la VM de pruebas (`test-nixos-vm`) en UTM, en el Mac,
y dejarla igual que estaba: toda la configuración está en este repo de GitHub.

Lo que **no** está en el repo y se pierde al borrar la VM: lo que haya en `~`
fuera de `~/nixos-config` (proyectos sin subir, descargas…), las sesiones
iniciadas (`gh`, Claude, Firefox) y las memorias e historial de Claude Code.

Tamaño: el sistema completo ocupa **~11 GiB** en disco; la descarga, comprimida,
rondará los 4 GiB (medido el 2026-11-25 con `nix path-info -Sh /run/current-system`).

## 1. Crear la VM en UTM (en el Mac)

1. Descargar la ISO **gráfica** de NixOS **26.05** para **aarch64** (ARM) desde
   <https://nixos.org/download>.
2. En UTM: *Create a New Virtual Machine* → **Virtualize** → **Linux** →
   elegir la ISO.
3. Ajustes (los de la VM anterior): **5 CPU**, **8 GB de RAM**, disco de
   **50 GB** (no más de lo que tenga libre el Mac).
4. Pantalla: la tarjeta **sin** aceleración OpenGL (la que no termina en
   `-gl`): la VM no tiene GPU y bspwm/picom van por CPU.
5. Antes de arrancar, en los ajustes de pantalla, desactivar el **Retina
   Mode**: con él bspwm se ve diminuto y la CPU dibuja 4 veces más píxeles.

Si se crea la VM nueva antes de borrar la vieja, el Mac necesita espacio para
las dos.

## 2. Instalar NixOS "de serie"

Con el instalador gráfico, lo normal:

- Idioma español, zona `Europe/Madrid`, teclado `es`.
- Usuario **`brais`** y su contraseña (la contraseña no está en el repo; se
  conserva la que se ponga aquí).
- Cualquier escritorio (se sustituye después).
- Disco: borrar el disco entero, sin cifrar, sin swap.

Al terminar: apagar, quitar la ISO en UTM (CD/DVD → *Clear*) y arrancar.

## 3. Aplicar la configuración del repo

En una terminal de la VM nueva:

```bash
nix-shell -p git
```
Abre una terminal con `git` disponible solo temporalmente (la instalación
limpia no lo trae).

```bash
git clone https://github.com/braiso-22/nixos-config ~/nixos-config
```
Descarga la configuración.

```bash
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hosts/test-nixos-vm/
```
**Paso imprescindible.** Ese archivo lo genera el instalador y dice, entre
otras cosas, qué disco es cada cosa (por UUID). La VM nueva tiene discos con
UUID distintos: con el archivo viejo **no arrancaría**.

```bash
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake ~/nixos-config#test-nixos-vm
```
Aplica toda la configuración. `NIX_CONFIG` activa los flakes solo para este
comando (la instalación limpia no los trae; a partir de aquí ya quedan
activados). El `#test-nixos-vm` es obligatorio la primera vez porque el
instalador llama al equipo `nixos`; después basta con el alias `rebuild`.

Después, **reiniciar la VM**: el login pasa a SDDM con la sesión bspwm, y
el teclado (tildes) y el scroll no cambian hasta reiniciar.

## 4. Remates

```bash
cd ~/nixos-config && git add hosts/test-nixos-vm/hardware-configuration.nix && git commit -m "hardware-configuration de la VM reinstalada" && git push
```
Guarda en GitHub el `hardware-configuration.nix` nuevo (antes hay que hacer
`gh auth login`, abajo).

```bash
sudo mv /etc/nixos /etc/nixos.bak && sudo ln -s ~/nixos-config /etc/nixos
```
Opcional: `/etc/nixos` apunta al repo, como en la VM anterior.

- `gh auth login`: sesión de GitHub en la terminal (para `push`, PRs…).
- Iniciar sesión en Claude y en Firefox.

## Si algo falla

- **"does not exist"** al hacer `switch`: Nix solo ve los archivos añadidos a
  git. Un archivo nuevo necesita `git add` antes.
- **"No space left on device"**: el disco es pequeño para el sistema. Agrandarlo
  en UTM (ver `implementado/2026-10-09-disco-y-limpieza.md`).
- **No arranca tras el `switch`**: probablemente el `hardware-configuration.nix`
  no es el de esta VM. En el menú de arranque (systemd-boot) elegir la
  generación anterior, copiar el archivo correcto y repetir.
