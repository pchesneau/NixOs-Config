# The main user (`machine.mainUser`): their roles from nixos-roles, and their
# home on top of them.
{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
  inherit (config.machine) mainUser;
in
{
  flake.modules.nixos.main-user =
    { lib, ... }:
    {
      roles.users.${mainUser.username} = [
        "base"
        "ops"
        "dev"
        "llm"
      ];

      users.users.${mainUser.username}.home = lib.mkIf (
        mainUser.homeDirectory != null
      ) mainUser.homeDirectory;

      home-manager.users.${mainUser.username}.imports = [ homeManager.main-user ];
    };

  flake.modules.homeManager.main-user = {
    imports = with homeManager; [
      catppuccin
      revim
      zellij
      claude-code
    ];

    programs.git.settings.user = {
      name = mainUser.gitUserName;
      email = mainUser.gitUserEmail;
    };

    roles.ops.azure.enable = true;
  };
}
