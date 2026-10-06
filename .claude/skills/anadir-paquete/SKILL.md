---
name: anadir-paquete
description: Añade un programa o paquete a la configuración de NixOS de este repo. Úsala cuando el usuario pida instalar, añadir o tener disponible un programa ("instala vlc", "quiero htop", "añade un editor"). Comprueba el nombre exacto en el nixpkgs fijado, lo añade, valida que compila y da el comando para aplicarlo.
---

# Añadir un paquete

Recuerda: el usuario es principiante; explica en español cada paso en una frase.

## 1. Encontrar el nombre exacto

El nombre que dice el usuario no siempre es el atributo de nixpkgs (p. ej. "vs code" → `vscode`, "obs" → `obs-studio`). Compruébalo siempre contra el nixpkgs **fijado en `flake.lock`**, no contra unstable:

```bash
nix eval --raw .#nixosConfigurations.nixos.pkgs.<attr>.meta.description
nix eval .#nixosConfigurations.nixos.pkgs.<attr>.meta.available   # true = funciona en aarch64-linux
```

Si no adivinas el atributo, busca en el mismo nixpkgs (la revisión es la del nodo al que apunta `root.inputs.nixpkgs` en `flake.lock`):

```bash
nix search github:NixOS/nixpkgs/<rev> '<regex>'
```

La primera búsqueda evalúa todo nixpkgs: tarda varios minutos y usa mucha memoria en esta VM de ~8 GB, así que lánzala en segundo plano y avisa al usuario; las siguientes van rápidas por la caché. Si hay varios candidatos, enséñaselos con su descripción y pregunta cuál quiere. Si `meta.available` es `false`, díselo: no está disponible para ARM.

## 2. Elegir dónde añadirlo

- Si existe módulo (`nix eval .#nixosConfigurations.nixos.options.programs --apply 'builtins.hasAttr "<nombre>"'` da `true`), usa `programs.<nombre>.enable = true;` junto a `programs.git.enable` en `configuration.nix`. Los módulos configuran además lo que el programa necesita (servicios, permisos).
- Si no, añádelo a `environment.systemPackages`. En `configuration.nix` ese bloque viene comentado de la instalación: la primera vez descoméntalo (quitando los ejemplos `vim`/`wget` si el usuario no los pidió) en lugar de crear un segundo bloque.

## 3. Validar

```bash
nixos-rebuild dry-build --flake .#nixos
```

Si falla, lee el error, corrígelo y vuelve a validar. Si va bien, dile al usuario el tamaño de descarga que aparece en `these N paths will be fetched (X MiB download…)`.

## 4. Aplicar y commit

Dale el comando (tú no puedes usar `sudo`):

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

Cuando diga que ha terminado, lee su terminal para comprobar que acabó con `Done.` sin errores. Después propón un mensaje de commit en español (p. ej. `Añadir htop`) y **pregunta antes de hacer commit**.
