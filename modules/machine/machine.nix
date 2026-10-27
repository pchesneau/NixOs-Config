# Machine-specific settings, from git-ignored files next to flake.nix: they
# are only visible when the flake is referenced as `path:/etc/nixos`, which
# makes Nix copy untracked files. flake.lock stays shareable between machines.
{ lib, ... }:
let
  mainUserFile = ../.. + "/mainUser.nix";
  additionalTrustsFile = ../.. + "/additional-trusts.crt";
in
{
  options.machine = {
    mainUser = lib.mkOption {
      type = lib.types.submodule {
        options = {
          username = lib.mkOption { type = lib.types.str; };
          gitUserName = lib.mkOption { type = lib.types.str; };
          gitUserEmail = lib.mkOption { type = lib.types.str; };
          homeDirectory = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Home directory, when not /home/<username>.";
          };
        };
      };
      description = "The main user, from mainUser.nix (see exemple_profile.nix).";
    };

    additionalTrusts = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Additional root certificates, from additional-trusts.crt.";
    };
  };

  config.machine = {
    mainUser =
      if builtins.pathExists mainUserFile then
        import mainUserFile
      else
        throw ''
          /etc/nixos/mainUser.nix not found. Create it from exemple_profile.nix,
          then build with `nh os switch` or
          `nixos-rebuild switch --flake path:/etc/nixos#nixos`
          (a plain /etc/nixos reference ignores git-ignored files).
        '';

    additionalTrusts = lib.mkIf (builtins.pathExists additionalTrustsFile) additionalTrustsFile;
  };
}
