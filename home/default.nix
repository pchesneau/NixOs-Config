# Reusable base home profile. The user's name and git identity come from
# flake.nix (/etc/nixos-config/mainUser.nix), as do the modules of the
# `catppuccin`, `lazyvim` and `revim` options.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./revim.nix ];

  # Keep in sync with the release Home Manager was installed from.
  home.stateVersion = "26.05";

  # User-scoped packages only (installed into /etc/profiles/per-user/<user>).
  home.packages =
    with pkgs;
    [
      # Cloud / Kubernetes tooling (backs the azure/kubectl/helm oh-my-zsh plugins).
      azure-cli
      kubernetes-helm
      fluxcd
      kubectl
      lazyssh
      github-copilot-cli
      any-nix-shell

      nom
      up
      nixfmt
      nh
      jq
      fzf
      ripgrep
      fd
      bat
      claude-code
    ]
    ++ [
      # Adds the latest IDEA version with the latest compatible version of "com.intellij.plugins.watcher".
      (pkgs.buildIdeWithPlugins "idea" [
        "com.intellij.plugins.watcher"
        "org.jetbrains.junie"
        "com.intellij.mcpServer"
        "com.intellij.ml.llm"
        "com.agentport.jetbrains-acp"
      ])
    ];

  # LazyVim, wired through Nix: plugins are injected as pinned `dev` specs
  # pointing at store paths, treesitter parsers are prebuilt, and Mason is
  # disabled (its prebuilt binaries cannot run outside an FHS environment).
  # Consequences: `~/.config/nvim` is read-only and `:Lazy update` does
  # nothing; plugins move when `lazyvim` is updated in flake.lock.
  programs.lazyvim = {
    enable = true;

    # LSP servers, formatters and linters that LazyVim would otherwise expect
    # Mason to provide. They land on neovim's wrapper PATH, not in the profile.
    extraPackages = with pkgs; [
      nil
      yaml-language-server
      jdt-language-server
      lua-language-server
      stylua
    ];

    extras.lang = {
      nix.enable = true;
      json = {
        enable = true;
        installDependencies = true;
      };
      yaml.enable = true;
      terraform = {
        enable = true;
        installDependencies = true;
      };
      markdown = {
        enable = true;
        installDependencies = true;
        installRuntimeDependencies = true;
      };
    };
  };

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
  };

  programs.zellij = {
    enable = true;
    # Auto-started from programs.zsh.initContent instead, with a stricter guard.
    enableZshIntegration = false;
    plugins = with pkgs.zellijPlugins; [ autolock ];
    settings = {

      show_startup_tips = false;
    };
  };
  programs.home-manager.enable = true;

  # Modern replacement for `ls`, managed declaratively instead of via raw
  # package + manual shellAliases. Provides ls/ll/la/lt aliases itself.
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  # Smarter `cd`: tracks visited directories and jumps via frecency (`z foo`).
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Migrated from old/.gitconfig. Installs git into this user's profile only.
  # `user.name` and `user.email` are set by flake.nix.
  programs.git = {
    enable = true;
    settings = {
      core.autocrlf = "input";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  # Syntax-highlighted, side-by-side diffs as git's pager (diff/log/show/blame).
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    extraFlags = [ "--quiet" ];
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    initContent = lib.mkMerge [
      # Starts zellij, or attaches to its running session, in each terminal.
      # Replaces programs.zellij.enableZshIntegration (+ attachExistingSession),
      # whose guard only skips TERM=dumb: with systemd, WSL also opens a hidden
      # `login` session at boot, an interactive zsh on a pty nobody reads, with
      # an empty TERM and none of the WSL/WSLg variables. When it won the race
      # it started the zellij server, and every pane inherited its empty TERM:
      # zsh could no longer move the cursor back, so each repaint (syntax
      # highlighting, autosuggestions) was appended after the line instead of
      # overwriting it, and one keystroke showed up as many letters.
      (lib.mkOrder 200 ''
        if [[ -z "$ZELLIJ" && -n "$TERM" && "$TERM" != dumb ]]; then
          ${lib.getExe config.programs.zellij.finalPackage} attach -c
        fi
      '')
      ''
        any-nix-shell zsh | source /dev/stdin
        export GIT_AUTO_FETCH_INTERVAL=120 # in seconds
      ''
    ];

    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      # Left empty on purpose: Starship provides the prompt. The old config set
      # ZSH_THEME="agnoster" but also loaded the oh-my-zsh "starship" plugin,
      # which overrode it, so Starship was already the effective prompt.
      theme = "";

      # Migrated from old/.zshrc. The "starship" plugin is intentionally dropped:
      # programs.starship.enableZshIntegration already runs `starship init zsh`,
      # and loading both would register the prompt hooks twice.
      # "snap" is dropped too: NixOS has no snapd, so it only added dead aliases.
      plugins = [
        "git"
        "ssh"
        "direnv"
        "kubectl"
        "azure"
        "terraform"
        "git-prompt"
        "kubectx"
        "helm"
        "ansible"
        "git-auto-fetch"
      ];

    };

    # ls/ll/la/lt aliases are provided by programs.eza (git integration on).
    shellAliases = {
      cat = "bat --paging=never";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    # Migrated from old/starship.toml (Catppuccin powerline prompt; the palette
    # comes from `catppuccin.starship` below). Home Manager renders this back
    # out to ~/.config/starship.toml, so this attribute set is now the single
    # source of truth.
    #
    # Note: the many module `symbol` values are Nerd Font glyphs from the
    # Private Use Area; they render as boxes without a patched font.
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      c = {
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = " ";
      };
      character = {
        disabled = false;
        error_symbol = "[❯](bold fg:red)";
        success_symbol = "[❯](bold fg:green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:lavender)";
        vimcmd_replace_symbol = "[❮](bold fg:lavender)";
        vimcmd_symbol = "[❮](bold fg:green)";
        vimcmd_visual_symbol = "[❮](bold fg:yellow)";
      };
      cmd_duration = {
        disabled = false;
        format = " in $duration ";
        min_time_to_notify = 45000;
        show_milliseconds = false;
        show_notifications = true;
        style = "bg:lavender";
      };
      conda = {
        format = "[$symbol$environment ]($style)";
        ignore_base = false;
        style = "fg:crust bg:sapphire";
        symbol = "  ";
      };

      custom = {
        # Shows the git-auto-fetch (omz plugin) state next to the branch icon:
        #  -  (sync) when the branch tracks a remote and auto-fetch is enabled
        #  -  (pause) when the branch tracks a remote but auto-fetch is suspended
        #     (the plugin's guard file $GIT_DIR/NO_AUTO_FETCH is present)
        #  - nothing for local-only branches (no upstream to fetch from)
        git_auto_fetch = {
          command = ''
            upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
            if [ -z "$upstream" ]; then
              exit 0
            fi
            gitdir=$(git rev-parse --git-dir 2>/dev/null)
            if [ -f "$gitdir/NO_AUTO_FETCH" ]; then
              printf ''
            else
              printf ''
            fi
          '';
          description = "Shows whether omz's git-auto-fetch is enabled for the current branch";
          format = "[$output]($style)";
          style = "bg:yellow fg:crust";
          when = "true";
          require_repo = true;
          shell = [
            "sh"
            "--noprofile"
            "--norc"
          ];
        };
      };

      # Rendered on the second line next to the nix-shell indicator, since
      # both describe the environment loaded into the current directory.
      # Shown whenever an `.envrc` is in scope: a check mark once the
      # environment is loaded, an empty circle while it is not, plus a lock
      # or ban glyph when the `.envrc` still needs `direnv allow`.
      direnv = {
        disabled = false;
        format = "[$symbol$loaded$allowed ]($style)";
        symbol = " ";
        style = "italic fg:teal";
        loaded_msg = "";
        unloaded_msg = "";
        allowed_msg = "";
        not_allowed_msg = "󰷌";
        denied_msg = " ";
      };

      directory = {
        format = "[ $path ]($style)";
        style = "bg:peach fg:crust";
        # Fish-style: no fixed truncation cutoff, every ancestor directory is
        # abbreviated to its first character and only the final component is
        # shown in full.
        truncation_length = 1;
        fish_style_pwd_dir_length = 1;
        truncation_symbol = "…/";
      };
      hostname = {
        # Only rendered over SSH, so local shells stay uncluttered but a
        # remote session always makes the host obvious.
        ssh_only = true;
        format = "[@$hostname ](bg:red fg:crust)";
        disabled = false;
      };
      kubernetes = {
        disabled = false;
        format = "[[ $symbol$context( \($namespace\)) ](fg:crust bg:sapphire)]($style)";
        style = "bg:sapphire";
        symbol = "☸ ";
      };
      format = "[](red)$os$username$hostname[](bg:peach fg:red)$directory[](bg:yellow fg:peach)\${custom.git_auto_fetch}$git_branch$git_status[](fg:yellow bg:green)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:green bg:sapphire)$conda$kubernetes[](fg:sapphire bg:lavender)$time[ ](fg:lavender)$cmd_duration$line_break$direnv\$nix_shell\$character";
      git_branch = {
        format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
        style = "bg:yellow";
        symbol = "";
      };
      git_status = {
        format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
        style = "bg:yellow";
      };
      golang = {
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = "";
      };
      haskell = {
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = "";
      };
      java = {
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = " ";
      };
      kotlin = {
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = "";
      };
      line_break = {
        disabled = true;
      };
      nix_shell = {
        disabled = false;
        format = "[$symbol$state( \($name\))]($style) ";
      };
      nodejs = {
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = "";
      };
      os = {
        disabled = false;
        style = "bg:red fg:crust";
        symbols = {
          AOSC = "";
          Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "󰣇";
          Artix = "󰣇";
          CentOS = "";
          Debian = "󰣚";
          Fedora = "󰣛";
          Gentoo = "󰣨";
          Linux = "󰌽";
          Macos = "󰀵";
          Manjaro = "";
          Mint = "󰣭";
          Raspbian = "󰐿";
          RedHatEnterprise = "󱄛";
          Redhat = "󱄛";
          SUSE = "";
          Ubuntu = "󰕈";
          Windows = "";
        };
      };
      php = {
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = "";
      };
      python = {
        format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = "";
      };
      rust = {
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        style = "bg:green";
        symbol = "";
      };
      time = {
        disabled = false;
        format = "[[  $time ](fg:crust bg:lavender)]($style)";
        style = "bg:lavender";
        time_format = "%R";
      };
      username = {
        format = "[ $user]($style)";
        show_always = true;
        style_root = "bg:red fg:crust";
        style_user = "bg:red fg:crust";
      };
    };
  };

  # Per-directory environments. `nix-direnv` replaces direnv's own `use nix`
  # with a caching implementation that keeps the built shell alive as a GC
  # root, so re-entering a project directory does not re-evaluate the flake.
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    # direnv prints its export list on every directory change; the prompt
    # already reports the state, so the chatter is suppressed.
    silent = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # The theme of the home (catppuccin/nix), for the programs that opt in below.
  # revim (./revim.nix) follows it too.
  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    accent = "mauve";
    starship.enable = true;
    zellij.enable = true;
  };
}
