# The theme of the home, from catppuccin/nix, for the programs that opt in
# below. revim follows it too.
{ inputs, ... }:
{
  flake.modules.homeManager.catppuccin = {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];

    catppuccin = {
      enable = true;
      autoEnable = false;
      flavor = "mocha";
      accent = "mauve";
      starship.enable = true;
      zellij.enable = true;
    };
  };
}
