# The `nixos` host: NixOS on WSL, its main user (`wsl.defaultUser`) on zsh with
# a Home Manager profile. flake.nix supplies the user and the inputs.
{ config, pkgs, ... }:
{
  imports = [
    ./wsl.nix
    ./customisation.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";

  users.users.${config.wsl.defaultUser}.shell = pkgs.zsh;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".home-manager-overrided";
  };
}
