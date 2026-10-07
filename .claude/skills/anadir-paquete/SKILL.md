---
name: anadir-paquete
description: Añade un programa o paquete a la configuración de NixOS de este repo. Úsala cuando el usuario pida instalar, añadir o tener disponible un programa ("instala vlc", "quiero htop", "añade un editor"). Comprueba el nombre exacto en el nixpkgs fijado, lo añade, valida que compila y da el comando para aplicarlo.
---

# Añadir un paquete

Recuerda: el usuario es principiante; explica en español cada paso en una frase.

## 0. Documentar

Antes de tocar nada, crea `docs/todo/<paquete>.md` (plantilla en `docs/README.md`; para un paquete basta con unas líneas: para qué lo quiere el usuario y dónde se añade). Al terminar, muévelo a `docs/implementado/` con la fecha delante, dentro del mismo commit.

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

- **Programas del usuario** (herramientas de terminal, editores, apps de escritorio): en `home.nix` (Home Manager). Si Home Manager tiene módulo (`nix eval .#nixosConfigurations.nixos.config.home-manager.users.brais.programs --apply 'p: builtins.hasAttr "<nombre>" p'` da `true`), usa `programs.<nombre>.enable = true;` (configura también la integración con bash, git…). Si no, añádelo a `home.packages`.
- **Cosas del sistema** (servicios, drivers, lo que necesite root o permisos especiales): en `configuration.nix`. Si existe módulo NixOS (`nix eval .#nixosConfigurations.nixos.options.programs --apply 'builtins.hasAttr "<nombre>"'` da `true`), usa `programs.<nombre>.enable = true;`; si no, `environment.systemPackages`.
- Si dudas, pregunta al usuario explicando la diferencia en una frase.

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

Cuando diga que ha terminado, lee su terminal para comprobar que acabó con `Done.` sin errores. Después mueve el doc a `docs/implementado/`, propón un mensaje de commit en español (p. ej. `Añadir htop`) y **pregunta antes de hacer commit**.
