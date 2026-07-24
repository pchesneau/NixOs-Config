{
  inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager= {
                url = "github:nix-community/home-manager";
                inputs.nixpkgs.follows = "nixpkgs";
};
nixos-wsl= { url = "github:nix-community/NixOS-WSL/main";
                inputs.nixpkgs.follows = "nixpkgs";
};

};

 outputs = { self, nixpkgs, nixos-wsl, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "26.05";
            wsl.enable = true;
          }
        ];
      };
    };
  };
}