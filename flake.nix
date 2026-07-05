{
  description = "NixOS + Niri + Noctalia — Ryzen 5 5600G / RX 7600";

  # ── Cachix de Noctalia (obligatorio — sin esto compila desde fuente ~30 min) ──
  nixConfig = {
    extra-substituters        = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    # Base del sistema — mismo canal que tu config de Sway
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager — gestión declarativa de config de usuario (nuevo en este setup)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia v4 — desktop shell unificado (barra + dock + launcher + lock + notifs)
    # Rama legacy-v4: estable. La rama main es v5 en beta.
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri-flake — módulo NixOS + Home Manager para Niri compositor
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, noctalia, niri-flake, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # inputs se pasa como specialArgs para que configuration.nix y home.nix
      # puedan referenciar noctalia y niri-flake directamente
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix

        # Módulo NixOS de Niri: habilita el paquete, portales y sistema base
        #niri-flake.nixosModules.niri

        # Módulo NixOS de Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs    = true;   # usa el mismo nixpkgs del sistema
          home-manager.useUserPackages  = true;   # instala paquetes HM en el perfil del usuario
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.lonso      = import ./home.nix;
        }
      ];
    };
  };
}
