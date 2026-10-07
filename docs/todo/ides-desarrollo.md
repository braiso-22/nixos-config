# Fase 3: IDEs y entornos de desarrollo

- **Estado:** en curso (VS Code hecho; faltan JetBrains Toolbox y plantillas)
- **Fecha:** 2026-10-07 (inicio)
- **Commit / tag:** —

## Contexto
Lenguajes con los que se trabaja: **Kotlin, TypeScript y C#**. IDEs elegidos:
**VS Code** y **JetBrains Toolbox** (para instalar IntelliJ IDEA y Rider).

## Decisiones
- **VS Code** (oficial de Microsoft, no VSCodium) con `programs.vscode` de Home
  Manager: extensiones y `settings.json` declarados en el repo.
  Comprobado: `vscode` 1.119 está disponible para aarch64-linux.
- **JetBrains Toolbox**: comprobado que `jetbrains-toolbox` existe para
  aarch64-linux. Los IDEs que instala Toolbox son binarios descargados, no de
  nixpkgs; puede que necesiten `programs.nix-ld` (ya activado) y librerías extra.
  Alternativa si falla: `jetbrains.idea` y `jetbrains.rider` de nixpkgs
  (`idea-community` ya no existe; JetBrains lo unificó en `idea`).
- **Perfiles de VS Code declarados en Nix** (`programs.vscode.profiles.<nombre>`),
  uno por lenguaje: `default` (solo comunes: repo NixOS y cosas sueltas),
  `typescript` (ESLint, Prettier) y `csharp` (C#, C# Dev Kit). **Sin perfil
  `kotlin`** (ver más abajo). Configuración en `vscode.nix`, importado desde
  `home.nix`. Extensiones y ajustes comunes se definen una vez en un `let` y se
  suman a cada perfil. VS Code recuerda qué perfil usa cada carpeta; también
  `code --profile <nombre> .`.
  - Consecuencia aceptada: con perfiles además de `default`, Home Manager exige
    `mutableExtensionsDir = false`: **todas las extensiones van en el repo**, no
    se instalan desde el botón del marketplace.
  - VS Code debe estar **cerrado** al aplicar un cambio que crea perfiles
    (Home Manager los registra en `globalStorage/storage.json`).
  - Alternativas descartadas: perfiles a mano en VS Code (no reproducible) y
    sin perfiles (todas las extensiones en todos los proyectos).
- Las extensiones salen de **nixpkgs** (`pkgs.vscode-extensions`). Comprobado
  para ARM: están C#, C# Dev Kit, ESLint, Prettier, Gradle, Nix IDE, direnv y
  GitLens. De Kotlin solo `mathiasfrohlich.kotlin` (colores, sin autocompletado).
- **Perfil `kotlin` descartado por tamaño.** La extensión buena es la oficial,
  `JetBrains.kotlin-server` (tiene versión `linux-arm64`), pero no está en
  nixpkgs y pesa 353 MiB (trae un JRE y el motor de IntelliJ). Como Kotlin se
  va a usar en IntelliJ, sería redundante. Alternativa ligera descartada:
  `fwcd.kotlin` (1 MiB, pero descarga su servidor al usarla y está abandonada
  en favor de la oficial).
- **Flake `nix-vscode-extensions`** (copia del marketplace, nix-community): se
  decidió añadirlo para lo que no está en nixpkgs, pero **se quitó** junto con
  el perfil de Kotlin, que era lo único que lo usaba. Para recuperarlo:
  - input con `inputs.nixpkgs.follows = "nixpkgs"` y su `overlays.default` en
    `nixpkgs.overlays` (en `flake.nix`);
  - en `vscode.nix`:
    `(pkgs.nix-vscode-extensions.forVSCodeVersion pkgs.vscode.version).vscode-marketplace-release.<publisher>.<nombre>`
    (nombres en minúsculas). `-release` = solo versiones estables;
    `forVSCodeVersion` = solo las compatibles con el VS Code de nixpkgs.
- Comunes a todos los perfiles: Nix IDE (con el servidor de lenguaje `nil`),
  direnv (`mkhl.direnv`: hace que VS Code cargue el entorno del `devShell` del
  proyecto, imprescindible para que encuentre node/dotnet/JDK) y GitLens.
  Ajustes comunes: fuente JetBrainsMono Nerd Font (editor y terminal),
  formatear al guardar, telemetría desactivada y sin avisos de actualización
  (las actualizaciones las gestiona Nix).
- **Guardado automático** tras 1 s sin escribir (`files.autoSave = "afterDelay"`,
  elegido por el usuario). Ese guardado no aplica `formatOnSave`; formatear al
  guardar sigue activo para los guardados a mano (Ctrl+S). Alternativa
  descartada: `onFocusChange` (sí formatea, pero guarda menos a menudo).
- **Formateo de Nix con nixfmt** (estilo oficial). Al principio se quiso evitar
  porque reescribiría los archivos al guardar, y se dejó sin configurar
  formateador; pero `nil` de nixpkgs **trae nixfmt incorporado**, y al guardar
  `flake.nix` en VS Code se reformateó entero. Se decidió adoptarlo: todo el
  repo se formatea una vez con nixfmt en un commit aparte (solo estilo), y el
  formateador queda explícito en `nix.serverSettings` y en la terminal
  (`nixfmt` en `home.packages`). `hardware-configuration.nix` no se formatea
  (lo genera `nixos-generate-config`).
- Uso previsto: Kotlin en IntelliJ; TypeScript en VS Code; C# en VS Code o Rider.
- **No instalar lenguajes a nivel global** (JDK, Node, .NET): cada proyecto
  declara los suyos en un `flake.nix` con `devShell` y se cargan solos con
  direnv (`.envrc` con `use flake`). Así cada proyecto tiene sus versiones.

## Plan
- [x] Investigar `nix-vscode-extensions` y Kotlin (descartado, ver arriba)
- [x] `vscode.nix`: perfiles default / typescript / csharp, extensiones y ajustes comunes
- [x] `dry-build`: 41 MiB de caché + ~400 MiB que se bajan al compilar (VS Code
      196 MiB, extensiones C# 204 MiB: lo no libre no está en la caché de NixOS
      y `dry-build` no lo cuenta)
- [x] Aplicar, abrir VS Code y comprobar los perfiles
- [ ] JetBrains Toolbox; probar que IntelliJ y Rider arrancan
- [ ] Plantillas de `devShell` para Kotlin (JDK + gradle), TypeScript (node +
      pnpm) y C# (dotnet-sdk). Decidir dónde guardarlas (¿`templates/` en este
      repo, usables con `nix flake init -t`?)
- [ ] Probar un proyecto de ejemplo de cada lenguaje

## Resultado
### VS Code (2026-10-07)
- VS Code 1.119.0; el `switch` tardó ~2 min (descarga VS Code y extensiones C#).
- `code --list-extensions --profile <perfil>` confirma cada perfil: Default
  (Nix IDE, direnv, GitLens), typescript (+ ESLint, Prettier), csharp (+ C#,
  C# Dev Kit, .NET runtime).
- Cómo funciona por dentro: todas las extensiones se instalan en
  `~/.vscode/extensions/` y cada perfil tiene su `extensions.json` con su lista
  (`~/.config/Code/User/profiles/<perfil>/`). Los perfiles se registran en
  `~/.config/Code/User/globalStorage/storage.json`.
