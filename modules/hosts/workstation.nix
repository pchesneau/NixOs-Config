# The host, published as `nixosConfigurations.nixos` (NixOS-WSL's default
# hostname): the WSL platform of nixos-roles, the main user, and the
# packages of this flake.
{ config, inputs, ... }:
let
  inherit (config.flake) overlays;
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.workstation = {
    imports = [
      inputs.nixos-roles.modules.nixos.wsl
      nixos.certificates
      nixos.main-user
    ];

    system.stateVersion = "26.05";

    nixpkgs.overlays = [ overlays.default ];

    # Makes `nh os switch` read the git-ignored machine-specific files.
    programs.nh.flake = "path:/etc/nixos";
  };

  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixos.workstation
      { nixpkgs.hostPlatform = "x86_64-linux"; }
    ];
  };
}
