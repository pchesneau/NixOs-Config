# Zellij, started from zsh with a stricter guard than Home Manager's
# integration (enabled by the base role), whose guard only skips TERM=dumb:
# with systemd, WSL also opens a hidden `login` session at boot, an
# interactive zsh on a pty nobody reads, with an empty TERM and none of the
# WSL/WSLg variables. When it won the race it started the zellij server, and
# every pane inherited its empty TERM: zsh could no longer move the cursor
# back, so each repaint (syntax highlighting, autosuggestions) was appended
# after the line instead of overwriting it.
{
  flake.modules.homeManager.zellij =
    { config, lib, ... }:
    {
      programs.zellij = {
        enableZshIntegration = lib.mkForce false;
        attachExistingSession = lib.mkForce false;
      };

      # Starts zellij, or attaches to its running session, in each terminal.
      programs.zsh.initContent = lib.mkOrder 200 ''
        if [[ -z "$ZELLIJ" && -n "$TERM" && "$TERM" != dumb ]]; then
          ${lib.getExe config.programs.zellij.finalPackage} attach -c
        fi
      '';
    };
}
