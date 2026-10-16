{ lib, pkgs, ... }: {

  config = {
    # home-manager.useGlobalPkgs = true (default.nix) means Home Manager
    # reuses this very nixpkgs instance.
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "barbar.nvim" # revim's file tabs
        "claude-code"
        "idea"
        "intellij-idea"
        "intellij-idea-with-plugins"
        "idea-with-plugins"
        "github-copilot-cli"
        # Pulled in by the LazyVim `lang.terraform` extra.
        "terraform"
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
      "configurable-impure-env"
    ];

    nix.settings."impure-env" = [ "NIX_CURL_FLAGS" ];
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];
    # Keep /nix/store from growing unbounded: weekly GC of old generations
    # plus store optimisation (hardlinking identical files) on a schedule,
    # which matters most on WSL's size-capped virtual disk.
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    # Enables zsh support (/etc/shells, /etc/zshenv) so it is a usable
    # login shell. This does not change anyone's shell on its own:
    # users.defaultUserShell stays bash, only pierre is switched to zsh.
    programs.zsh.enable = true;
  };
}
