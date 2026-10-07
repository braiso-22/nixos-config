# Fase 3: IDEs y entornos de desarrollo

- **Estado:** pendiente
- **Fecha:** —
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
- **No instalar lenguajes a nivel global** (JDK, Node, .NET): cada proyecto
  declara los suyos en un `flake.nix` con `devShell` y se cargan solos con
  direnv (`.envrc` con `use flake`). Así cada proyecto tiene sus versiones.

## Plan
- [ ] VS Code con extensiones: Nix IDE, Kotlin, ESLint, Prettier, C# Dev Kit
      (comprobar cuáles hay en nixpkgs para aarch64; si no, decidir si se dejan
      mutables con `mutableExtensionsDir`)
- [ ] Ajustes de VS Code: fuente JetBrainsMono Nerd Font, formato al guardar…
- [ ] JetBrains Toolbox; probar que IntelliJ y Rider arrancan
- [ ] Plantillas de `devShell` para Kotlin (JDK + gradle), TypeScript (node +
      pnpm) y C# (dotnet-sdk). Decidir dónde guardarlas (¿`templates/` en este
      repo, usables con `nix flake init -t`?)
- [ ] Probar un proyecto de ejemplo de cada lenguaje

## Resultado
