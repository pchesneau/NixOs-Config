{ lib, pkgs, ... }: {

  config = {
    # home-manager.useGlobalPkgs = true below means Home Manager reuses
    # this very nixpkgs instance.
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "idea"
        "intellij-idea"
        "intellij-idea-with-plugins"
        "idea-with-plugins"
        "github-copilot-cli"
      ];

    time.timeZone = "Europe/Paris";
    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    # Enable the modern Nix CLI permanently, so `nix build`, `nix eval`,
    # `nix flake ...` and friends work without repeating
    # --extra-experimental-features on every invocation. This writes
    # experimental-features into /etc/nix/nix.conf, so it applies to
    # every user on the system, not just interactive shells.
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Enables zsh support (/etc/shells, /etc/zshenv) so it is a usable
    # login shell. This does not change anyone's shell on its own:
    # users.defaultUserShell stays bash, only pierre is switched to zsh.
    programs.zsh.enable = true;
    users.users.pierre.shell = pkgs.zsh;
  };
}
