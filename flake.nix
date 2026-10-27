{
  description = "NixOS on WSL for development, built on the nixos-roles modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:denful/import-tree";

    # The NixOS and Home Manager modules this configuration is built on: the
    # WSL platform, the roles and their defaults.
    nixos-roles = {
      url = "github:maximeq95/NixOs-Opinionated/refactor/dendritic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
      };
    };

    # The theme of the home (`catppuccin.flavor` / `catppuccin.accent`).
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # revim: Neovim (nixvim) and a yazi + zellij IDE around it. Its overlay adds
    # `pkgs.revim`, its Home Manager module `programs.revim`.
    revim = {
      url = "github:maximeq95/revim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "nixos-roles/home-manager";
      };
    };
  };

  # Dendritic layout: every file under ./modules is a flake-parts module,
  # imported automatically (paths containing `/_` are skipped). See README.md.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
