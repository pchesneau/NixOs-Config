{
  description = "NixOS on WSL with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-jetbrains-plugins = {
      url = "github:nix-community/nix-jetbrains-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
    };

    # Home Manager module exposing `programs.lazyvim`. It patches the upstream
    # LazyVim starter config so every plugin, treesitter parser and LSP binary
    # is resolved through Nix instead of being downloaded at runtime.
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # The theme of the whole home (`catppuccin.flavor` / `catppuccin.accent`).
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # revim: Neovim (nixvim) and a yazi + zellij IDE around it. Its overlay adds
    # `pkgs.revim`, its Home Manager module `programs.revim` (home/revim.nix).
    revim = {
      url = "github:maximeq95/revim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.home-manager.follows = "home-manager";
    };

    user-provided-config = {
      url = "path:///etc/nixos-config";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      nixos-wsl,
      nix-jetbrains-plugins,
      lazyvim,
      catppuccin,
      revim,
      user-provided-config,
    }:
    {
      overlays.default = final: prev: {
        # `pkgs.buildIdeWithPlugins "idea" [ "<plugin id>" … ]`: a JetBrains IDE with its plugins.
        buildIdeWithPlugins = nix-jetbrains-plugins.lib.buildIdeWithPlugins final;
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/nixos
          # What the host takes from this flake and from /etc/nixos-config.
          (
            let
              mainUser = import "${user-provided-config}/mainUser.nix";
              additionalTrusts = "${user-provided-config}/additional-trusts.crt";
            in
            {
              nixpkgs.overlays = [
                self.overlays.default
                revim.overlays.default
              ];
              security.pki.certificateFiles = nixpkgs.lib.optional (builtins.pathExists additionalTrusts) additionalTrusts;
              wsl.defaultUser = mainUser.username;
              home-manager.sharedModules = [
                catppuccin.homeModules.catppuccin
                lazyvim.homeManagerModules.default
                revim.homeModules.default
              ];
              home-manager.users.${mainUser.username} = {
                imports = [ ./home ];
                programs.git.settings.user = {
                  name = mainUser.gitUserName;
                  email = mainUser.gitUserEmail;
                };
              };
            }
          )
        ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    });
}
