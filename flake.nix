{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
      nixos-wsl,
      home-manager,
      nix-jetbrains-plugins,
      user-provided-config,
      ...
    }@inputs:
    {
      nixosConfigurations =
        let
          mainUserConfig = import "${inputs.user-provided-config}/mainUser.nix";
        in
        {
          nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./system-config.nix
              nixos-wsl.nixosModules.default
              {
                security.pki.certificateFiles =
                  nixpkgs.lib.mkIf (builtins.pathExists "${inputs.user-provided-config}/additional-trusts.crt")
                    [ "${inputs.user-provided-configg}/additional-trusts.crt" ];
              }
              ./wsl-base-config.nix
              ./system-customisation.nix
              {
                wsl.defaultUser = mainUserConfig.username;
              }
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs; };
                home-manager.users."${mainUserConfig.username}" = import ./home_base.nix mainUserConfig;
              }
            ];
          };
        };
    };
}
