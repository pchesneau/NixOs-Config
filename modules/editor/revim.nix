# revim (github:maximeq95/revim) as the editor and IDE, in place of the
# LazyVim of the base role: both ship `nvim`, `vi` and `vim`. Its package
# comes from its overlay, composed into `overlays.default`.
{ inputs, ... }:
{
  flake.overlays.revim = inputs.revim.overlays.default;

  flake.modules.homeManager.revim =
    { lib, ... }:
    {
      imports = [
        inputs.revim.homeModules.default
        # Declares `programs.lazyvim` and `roles.unfreePackages`.
        inputs.nixos-roles.modules.homeManager.common
      ];

      programs.lazyvim.enable = lib.mkForce false;

      programs.revim = {
        enable = true;
        defaultEditor = true;
        clipboard = "wl-copy"; # WSLg; clip.exe is off the PATH (wsl.interop.includePath = false)
        # nixd completes the options of the flake being edited, wherever it is
        # cloned: its `nixos` configuration, Home Manager's included.
        extraConfig.lsp.servers.nixd.config.on_init.__raw = ''
          function(client)
            local root = client.root_dir
            if not (root and vim.uv.fs_stat(root .. "/flake.nix")) then
              return
            end
            local nixos = ("(builtins.getFlake %q).nixosConfigurations.nixos.options or { }"):format(root)
            client.settings.nixd = vim.tbl_deep_extend("force", client.settings.nixd or {}, {
              options = {
                nixos = { expr = nixos },
                ["home-manager"] = {
                  expr = ("let o = %s; in if o ? home-manager then o.home-manager.users.type.getSubOptions [ ] else { }"):format(nixos),
                },
              },
            })
            client:notify("workspace/didChangeConfiguration", { settings = client.settings })
          end
        '';
      };

      # barbar.nvim: revim's file tabs; claude-code: its Claude integration.
      roles.unfreePackages = [
        "barbar.nvim"
        "claude-code"
      ];
    };
}
