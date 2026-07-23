{
  description = "WSL specific configuration for nixOS with Flakes";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }: {

        module=   nixos-wsl.nixosModules.default
          {

            wsl.enable = true;
            wsl.defaultUser = "nixos";
};
  };
}