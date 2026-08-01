{
  description = "Configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-discord.url = "github:ap-1/nixpkgs/discord-canary-osx-0.0.1159";
    nixpkgs-sunshine.url = "github:ap-1/nixpkgs/sunshine-update-2026.619";
    nixpkgs-moonshine.url = "github:ap-1/nixpkgs/moonshine";

    # Flake infrastructure
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/pull/1818/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System modules
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    mt7927 = {
      url = "github:cmspam/mt7927-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-pkgs = {
      url = "git+https://codeberg.org/anish/llm-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ncro = {
      url = "github:feel-co/ncro";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tangled = {
      url = "git+https://tangled.org/tangled.org/core";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gwfox = {
      url = "github:akkva/gwfox/2bd70d4142737c70832e44d742ed97a49c026f03";
      flake = false;
    };
    xdg-termfilepickers = {
      url = "github:Guekka/xdg-desktop-portal-termfilepickers/9a4a40fee7a6973f581404b6fa1f1107026d05f8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moonlight = {
      url = "github:moonlight-mod/moonlight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moonshine = {
      url = "github:hgaiser/moonshine/v0.14.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omp-nix = {
      url = "git+https://git.molez.org/mandlm/omp-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.treefmt-nix.flakeModule
        (inputs.import-tree ./modules)
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem = { ... }: {
        treefmt = {
          programs = {
            jsonfmt.enable = true;
            mdformat.enable = true;
            nixfmt.enable = true;
            shfmt.enable = true;
            stylua.enable = true;
            terraform.enable = true;
          };
        };
      };
    };
}
