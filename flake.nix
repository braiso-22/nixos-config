{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    claude-desktop.url = "github:poeck/claude-desktop-nix-flake";
    # Home Manager: configuración de cada usuario (dotfiles), en modules/home y
    # users/<persona>/home.nix. La rama release-26.05 va a juego con nixpkgs, y
    # "follows" hace que use el mismo nixpkgs que el sistema en vez de otro.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Stylix: un tema de colores y fuentes para todo (modules/nixos/tema.nix).
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      # Un equipo = lo común (modules/nixos) + su máquina (hosts/<host>) + las
      # personas que lo usan (users/<persona>).
      mkHost =
        { host, users }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; }; # los módulos reciben los inputs del flake
          modules = [
            ./modules/nixos
            (./hosts + "/${host}")
          ]
          ++ map (persona: ./users + "/${persona}") users;
        };
    in
    {
      nixosConfigurations = {
        nixos = mkHost {
          host = "nixos"; # la VM
          users = [ "brais" ];
        };
      };

      # Plantillas de proyecto: nix flake init -t ~/nixos-config#<nombre>
      templates =
        let
          bienvenida = editor: ''
            Entorno creado (flake.nix y .envrc). Siguientes pasos:
              1. git add flake.nix .envrc   # si el proyecto usa git: Nix solo ve lo añadido
              2. direnv allow               # permite cargar el entorno en esta carpeta
              3. Añade .direnv/ al .gitignore del proyecto
              4. ${editor}
          '';
        in
        {
          kotlin = {
            path = ./templates/kotlin;
            description = "Proyecto Kotlin: JDK 25 (Gradle con ./gradlew)";
            welcomeText = bienvenida "Compila y ejecuta desde la terminal: ./gradlew run";
          };
          typescript = {
            path = ./templates/typescript;
            description = "Proyecto TypeScript: Node 24 LTS y pnpm";
            welcomeText = bienvenida "Abre VS Code desde aquí: code --profile typescript .";
          };
          csharp = {
            path = ./templates/csharp;
            description = "Proyecto C#: .NET SDK 10 LTS";
            welcomeText = bienvenida "Abre VS Code desde aquí: code --profile csharp .";
          };
        };
    };
}
