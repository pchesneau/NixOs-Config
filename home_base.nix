# Reusable base home profile.
#
# This file is a function of the user's identity: apply it to an attribute set
# to get a Home Manager module.
{
  username,
  gitUserName,
  gitUserEmail,
  ...
}:

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keep in sync with the release Home Manager was installed from.
  home.stateVersion = "26.05";

  # User-scoped packages only (installed into /etc/profiles/per-user/${username}).
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

      nil
      up
      nixfmt
      nh
      jq
      fzf
      ripgrep
      fd
      bat
      eza
    ]
    ++ [
      # Adds the latest IDEA version with the latest compatible version of "com.intellij.plugins.watcher".
      (inputs.nix-jetbrains-plugins.lib.buildIdeWithPlugins pkgs "idea" [
        "com.intellij.plugins.watcher"
        "org.jetbrains.junie"
        "com.intellij.mcpServer"
        "com.intellij.ml.llm"
        "com.agentport.jetbrains-acp"
      ])
    ];

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.home-manager.enable = true;

  # Migrated from old/.gitconfig. Installs git into this user's profile only.
  programs.git = {
    enable = true;
    settings = {
      user.name = gitUserName;
      user.email = gitUserEmail;

      core.autocrlf = "input";
      push.autoSetupRemote = true;
    };
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
        "kubectl"
        "azure"
        "terraform"
        "git-prompt"
        "kubectx"
        "helm"
        "ansible"
      ];

    };

    shellAliases = {
      ls = "eza";
      ll = "eza -l --git";
      la = "eza -la --git";
      lt = "eza --tree --level=2";
      cat = "bat --paging=never";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    # Migrated from old/starship.toml (Catppuccin Mocha powerline prompt).
    # Home Manager renders this back out to ~/.config/starship.toml, so this
    # attribute set is now the single source of truth.
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
        show_milliseconds = true;
        show_notifications = true;
        style = "bg:lavender";
      };
      conda = {
        format = "[$symbol$environment ]($style)";
        ignore_base = false;
        style = "fg:crust bg:sapphire";
        symbol = "  ";
      };
      directory = {
        format = "[ $path ]($style)";
        style = "bg:peach fg:crust";
        substitutions = {
          Developer = "󰲋 ";
          Documents = "󰈙 ";
          Downloads = " ";
          Music = "󰝚 ";
          Pictures = " ";
        };
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      docker_context = {
        format = "[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)";
        style = "bg:sapphire";
        symbol = "";
      };
      format = "[](red)$os$username[](bg:peach fg:red)$directory[](bg:yellow fg:peach)$git_branch$git_status[](fg:yellow bg:green)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:green bg:sapphire)$conda[](fg:sapphire bg:lavender)$time[ ](fg:lavender)$cmd_duration$line_break$character";
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
      palette = "catppuccin_mocha";
      palettes = {
        catppuccin_frappe = {
          base = "#303446";
          blue = "#8caaee";
          crust = "#232634";
          flamingo = "#eebebe";
          green = "#a6d189";
          lavender = "#babbf1";
          mantle = "#292c3c";
          maroon = "#ea999c";
          mauve = "#ca9ee6";
          overlay0 = "#737994";
          overlay1 = "#838ba7";
          overlay2 = "#949cbb";
          peach = "#ef9f76";
          pink = "#f4b8e4";
          red = "#e78284";
          rosewater = "#f2d5cf";
          sapphire = "#85c1dc";
          sky = "#99d1db";
          subtext0 = "#a5adce";
          subtext1 = "#b5bfe2";
          surface0 = "#414559";
          surface1 = "#51576d";
          surface2 = "#626880";
          teal = "#81c8be";
          text = "#c6d0f5";
          yellow = "#e5c890";
        };
        catppuccin_latte = {
          base = "#eff1f5";
          blue = "#1e66f5";
          crust = "#dce0e8";
          flamingo = "#dd7878";
          green = "#40a02b";
          lavender = "#7287fd";
          mantle = "#e6e9ef";
          maroon = "#e64553";
          mauve = "#8839ef";
          overlay0 = "#9ca0b0";
          overlay1 = "#8c8fa1";
          overlay2 = "#7c7f93";
          peach = "#fe640b";
          pink = "#ea76cb";
          red = "#d20f39";
          rosewater = "#dc8a78";
          sapphire = "#209fb5";
          sky = "#04a5e5";
          subtext0 = "#6c6f85";
          subtext1 = "#5c5f77";
          surface0 = "#ccd0da";
          surface1 = "#bcc0cc";
          surface2 = "#acb0be";
          teal = "#179299";
          text = "#4c4f69";
          yellow = "#df8e1d";
        };
        catppuccin_macchiato = {
          base = "#24273a";
          blue = "#8aadf4";
          crust = "#181926";
          flamingo = "#f0c6c6";
          green = "#a6da95";
          lavender = "#b7bdf8";
          mantle = "#1e2030";
          maroon = "#ee99a0";
          mauve = "#c6a0f6";
          overlay0 = "#6e738d";
          overlay1 = "#8087a2";
          overlay2 = "#939ab7";
          peach = "#f5a97f";
          pink = "#f5bde6";
          red = "#ed8796";
          rosewater = "#f4dbd6";
          sapphire = "#7dc4e4";
          sky = "#91d7e3";
          subtext0 = "#a5adcb";
          subtext1 = "#b8c0e0";
          surface0 = "#363a4f";
          surface1 = "#494d64";
          surface2 = "#5b6078";
          teal = "#8bd5ca";
          text = "#cad3f5";
          yellow = "#eed49f";
        };
        catppuccin_mocha = {
          base = "#1e1e2e";
          blue = "#89b4fa";
          crust = "#11111b";
          flamingo = "#f2cdcd";
          green = "#a6e3a1";
          lavender = "#b4befe";
          mantle = "#181825";
          maroon = "#eba0ac";
          mauve = "#cba6f7";
          overlay0 = "#6c7086";
          overlay1 = "#7f849c";
          overlay2 = "#9399b2";
          peach = "#fab387";
          pink = "#f5c2e7";
          red = "#f38ba8";
          rosewater = "#f5e0dc";
          sapphire = "#74c7ec";
          sky = "#89dceb";
          subtext0 = "#a6adc8";
          subtext1 = "#bac2de";
          surface0 = "#313244";
          surface1 = "#45475a";
          surface2 = "#585b70";
          teal = "#94e2d5";
          text = "#cdd6f4";
          yellow = "#f9e2af";
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

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };
}
