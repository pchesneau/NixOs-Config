# Claude Code, the AI coding assistant CLI.
{ inputs, ... }:
{
  flake.modules.homeManager.claude-code = {
    # Declares `roles.unfreePackages`.
    imports = [ inputs.nixos-roles.modules.homeManager.common ];

    programs.claude-code.enable = true;
    roles.unfreePackages = [ "claude-code" ];
  };
}
