# Fase 3: IDEs y entornos de desarrollo

- **Estado:** implementado
- **Fecha:** 2026-10-07 → 2026-10-08
- **Commit / tag:** 1da7164 (VS Code), 7607333 (nixfmt), 9752065 (IntelliJ), plantillas: ver tag 0.5.0

## Contexto
Lenguajes con los que se trabaja: **Kotlin, TypeScript y C#**. IDEs elegidos:
**VS Code** e **IntelliJ IDEA** (de nixpkgs). Se pidió JetBrains Toolbox,
pero se cambió (ver Decisiones). Rider, de momento no: C# en VS Code.

## Decisiones
- **VS Code** (oficial de Microsoft, no VSCodium) con `programs.vscode` de Home
  Manager: extensiones y `settings.json` declarados en el repo.
  Comprobado: `vscode` 1.119 está disponible para aarch64-linux.
- **IntelliJ IDEA de nixpkgs** (`pkgs.jetbrains.idea`, en `jetbrains.nix`), no
  JetBrains Toolbox. Motivos:
  - El paquete `jetbrains-toolbox` de nixos-26.05 está **roto**: fija la
    versión 3.1.0, que JetBrains retiró de su web (404). `master` ya tiene la
    3.8.1; se podía copiar su receta al repo, pero se descartó.
  - Pensando en compartir el setup con un equipo (~10 personas, ver
    `todo/ideas.md`): con nixpkgs **todos tienen la misma versión** (fijada
    en `flake.lock`), las actualizaciones las decide y prueba quien gestiona
    el repo, y volver atrás en NixOS restaura el IDE. Con Toolbox cada uno
    actualiza por su cuenta (versiones distintas, soporte más difícil), los
    IDEs viven en `~` fuera de Nix y dependen de `nix-ld` (se probó a darle
    las librerías de la burbuja FHS de Toolbox; se deshizo).
  - Contras aceptados: cada actualización descarga el IDE entero (no parches
    como Toolbox); las versiones llegan cuando nixpkgs estable las incorpora;
    otros IDEs hay que añadirlos al repo. Con un equipo: caché binaria propia
    (Attic/Cachix) para no descargar en cada máquina.
  - **Rider no** de momento (2,2 GB): C# en VS Code. Se añade con
    `pkgs.jetbrains.rider` en `jetbrains.nix`.
  - Uso: `idea .` desde la carpeta del proyecto para heredar el entorno de
    direnv (JDK, Gradle). Desde el menú no lo hereda.
  - Licencia (uso personal, sin licencia de pago): IntelliJ unificado (desde
    2025.3) es **gratis sin suscripción ni activación**, también para uso
    comercial, con todo lo de Java y Kotlin (y desde 2026.1 lo básico de
    JS/TS). Solo lo avanzado de Ultimate es de pago (prueba de 30 días: no
    hace falta). **Rider es gratis para uso no comercial** (licencia
    "Non-commercial use" desde Help → Manage Licenses con cuenta JetBrains,
    se renueva sola cada año si se usa); no se descartó por licencia sino por
    tamaño.
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
- **Plantillas en este repo** (`templates/<lenguaje>/`, salida `templates` de
  `flake.nix`), usables con `nix flake init -t ~/nixos-config#<lenguaje>`.
  Son independientes del editor: Kotlin se usa con IntelliJ (`idea .`), no
  con VS Code.
  - **kotlin**: solo `jdk25` (la versión de los proyectos actuales). **Sin
    `gradle` de nixpkgs**: los proyectos usan el wrapper (`./gradlew`) y el de
    nixpkgs es 8.14 (antiguo). Con el JDK en el entorno, Gradle lo detecta como
    toolchain y no descarga otro con foojay.
  - **typescript**: `nodejs_24` (LTS) y `pnpm`.
  - **csharp**: `dotnet-sdk_10` (LTS), con `DOTNET_ROOT` (lo necesita la
    extensión C# de VS Code) y telemetría de .NET desactivada.
  - Cada plantilla fija `nixos-26.05`; al crear el proyecto se genera su
    `flake.lock`, así que el proyecto conserva sus versiones aunque se
    actualice el sistema. Soportan aarch64/x86_64 Linux y Mac ARM (por si se
    comparten).
  - Sin `.gitignore` en la plantilla (chocaría con el del proyecto): el mensaje
    de bienvenida recuerda añadir `.direnv/`.
  - **Comando `nuevo-proyecto <lenguaje>`** (`nuevo-proyecto.nix`): hace
    `nix flake init`, fija nixpkgs a **la misma revisión que el sistema**
    (`nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/$(nixos-version --revision)`),
    `git add`, añade `.direnv/` al `.gitignore` y `direnv allow`. Motivo: con
    la última `nixos-26.05` (más nueva que la del sistema) no se reutiliza nada
    de lo instalado: Kotlin 627 → 94 MiB, TypeScript 177 → 144, C# 363 → 308
    (total 1,17 GB → 546 MiB, y lo mismo en disco). El lock guarda
    `original = nixos-26.05`, así que `nix flake update` en el proyecto lo
    lleva a la última estable, y apunta a GitHub (sirve en otra máquina).
    Alternativa descartada: registro `nixpkgs` del sistema (lock con ruta
    `/nix/store`, no portable).

## Plan
- [x] Investigar `nix-vscode-extensions` y Kotlin (descartado, ver arriba)
- [x] `vscode.nix`: perfiles default / typescript / csharp, extensiones y ajustes comunes
- [x] `dry-build`: 41 MiB de caché + ~400 MiB que se bajan al compilar (VS Code
      196 MiB, extensiones C# 204 MiB: lo no libre no está en la caché de NixOS
      y `dry-build` no lo cuenta)
- [x] Aplicar, abrir VS Code y comprobar los perfiles
- [x] Toolbox: paquete roto en 26.05 → IntelliJ de nixpkgs (ver Decisiones)
- [x] `dry-build` de IntelliJ: 2,0 GiB de caché (JDKs de JetBrains y
      herramientas para prepararlo) + 1,5 GB de JetBrains. Tras aplicar, la
      limpieza (`nix-collect-garbage`) libera lo que solo se usó para prepararlo
- [x] Aplicar y probar que IntelliJ arranca (2.º intento, tras liberar 17,5 GiB:
      OK en 7 min; **pico real de ~19 GB** de disco, no 10). Arranca bien;
      problema con Gradle en "Problemas conocidos".
      Historial del 1.er intento: **Primer intento fallido (2026-10-07):
      disco lleno** ("No space left on device" al copiar IntelliJ; la
      configuración activa no cambió). Prepararlo necesita a la vez el
      tarball, su versión descomprimida, la copia final y las herramientas
      de compilación (~10 GB de pico). Disco de 41 GB: sistema actual 9,5 GiB
      y ~20 GiB retenidos por 11 generaciones antiguas. Solución: borrar
      generaciones (dejar las 3 últimas) y limpiar; a medio plazo, agrandar
      el disco de la VM y activar la limpieza automática (ver `ideas.md`)
- [x] Plantillas en `templates/` (kotlin: jdk25; typescript: node 24 + pnpm;
      csharp: dotnet 10) y comando `nuevo-proyecto`
- [x] Probar cada plantilla en un proyecto nuevo con git: entornos cargan
      (JDK 25.0.4 + JAVA_HOME; node 24.21 + pnpm 11.27; dotnet 10.0.401 +
      DOTNET_ROOT) y un `dotnet new console` + `dotnet run` funciona
- [x] Aplicar (`nuevo-proyecto` está en home.nix; 2,6 MiB) y cerrar la fase:
      mover a implementado, commit y tag 0.5.0

## Resultado
### Resumen
- **VS Code** con perfiles default / typescript / csharp (`vscode.nix`).
- **IntelliJ IDEA** de nixpkgs (`jetbrains.nix`), gratis sin licencia para
  Kotlin. Rider no instalado (gratis para uso no comercial si hace falta).
- **Plantillas** `templates/{kotlin,typescript,csharp}` + comando
  **`nuevo-proyecto <lenguaje>`**. Uso:
  `mkdir app && cd app && git init && nuevo-proyecto typescript`.
- Todo el repo formateado con nixfmt.
- Pendiente fuera de esta fase: el fallo del plugin Kotlin Multiplatform
  (ver "Problemas conocidos") y el disco de 41 GB (ver `todo/ideas.md`).

### VS Code (2026-10-07)
- VS Code 1.119.0; el `switch` tardó ~2 min (descarga VS Code y extensiones C#).
- `code --list-extensions --profile <perfil>` confirma cada perfil: Default
  (Nix IDE, direnv, GitLens), typescript (+ ESLint, Prettier), csharp (+ C#,
  C# Dev Kit, .NET runtime).
- Cómo funciona por dentro: todas las extensiones se instalan en
  `~/.vscode/extensions/` y cada perfil tiene su `extensions.json` con su lista
  (`~/.config/Code/User/profiles/<perfil>/`). Los perfiles se registran en
  `~/.config/Code/User/globalStorage/storage.json`.

### Problemas conocidos de IntelliJ en esta VM (Linux ARM64)
- **"Unknown host target: linux aarch64" al ejecutar tareas Gradle desde el
  IDE** (aunque el proyecto sea solo Kotlin/JVM). Lo provoca el plugin
  **Kotlin Multiplatform** (`kmm-plugin`, instalado aparte, no viene de serie):
  intercepta cada ejecución de Gradle y pregunta por el host de Kotlin/Native,
  que no admite Linux ARM64. **Sin resolver:** se borró `kmm-plugin` y sigue
  fallando; la misma clase (`MPPDebugExecutionAware`) está también en
  `nativeDebug-plugin` (Native Debugging Support), que sigue instalado:
  probablemente haya que quitar ese también. Se aparcó (2026-10-08).
  Alternativas que no dependen de eso: `./gradlew` desde la terminal, o "Build and run using:
  IntelliJ IDEA". Kotlin/Native (KMP con targets nativos/iOS) no compila en
  Linux ARM64 en ningún caso: eso se hace en el Mac.
