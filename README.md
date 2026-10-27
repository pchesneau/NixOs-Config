# NixOS WSL Development Environment Configuration

A reproducible, declarative NixOS configuration for WSL (Windows Subsystem for Linux) powered by **Nix Flakes** and **Home Manager**.

This project bootstraps and manages a fully-configured developer environment on Windows WSL, complete with modern CLI utilities, shell optimizations, cloud/DevOps tooling, and declarative IDE configurations.

Most of the configuration comes from the [`NixOs-Opinionated`](https://github.com/pchesneau/NixOs-Opinionated) modules (input `nixos-roles`): the WSL platform and the `base`, `ops`, `dev` and `llm` roles. This repository picks them for the main user and adds its own features on top: the revim editor, the Catppuccin theme, Claude Code. See that repository's README for every available option and role.

---

## 🌟 What This Project Does

- **Declarative NixOS on WSL**: Leverages [`NixOS-WSL`](https://github.com/nix-community/NixOS-WSL) for lightweight, high-performance Linux on Windows without the overhead of standard virtualization.
- **Home Manager Integration**: Declaratively manages user profiles, dotfiles, and user packages.
- **Modern Shell & Terminal**:
  - **Zsh** with Oh-My-Zsh plugins (`git`, `ssh`, `kubectl`, `azure`, `terraform`, `kubectx`, `helm`, `ansible`).
  - **Starship Prompt**: Powerline prompt themed by [catppuccin/nix](https://github.com/catppuccin/nix) (Mocha). Inside a `nix-shell` / `nix develop` / `nix run`, the loaded packages are shown (via `any-nix-shell`) right before the prompt character, next to a `direnv` indicator.
  - **Zellij**: Terminal multiplexer, started (or attached to) by every terminal's zsh.
  - **direnv + nix-direnv**: Per-directory environments loaded on `cd`, with the built shell cached and kept alive as a GC root so re-entering a project is instant.
  - **Modern CLI Replacements**: `eza` (for `ls`), `bat` (for `cat`), `ripgrep` (`rg`), `fd`, `fzf`, `jq`, `up`, `lazyssh`.
- **Development & IDE**:
  - **revim**: [Neovim (nixvim) and a yazi + zellij IDE around it](https://github.com/maximeq95/revim), the default `$EDITOR`, also reachable as `vi` / `vim`.
  - **IntelliJ IDEA**: Declaratively provisioned with plugins via `nix-jetbrains-plugins` (File Watcher, Junie, MCP Server, ML LLM, ACP, Air).
  - **Claude Code** and **GitHub Copilot CLI**.
  - **Nix Tooling**: `nixfmt` code formatter and `nh` helper.
- **Cloud & DevOps Ready**: Preloaded with `kubectl`, `helm`, `fluxcd`, `terraform`, `ansible` and the Azure CLI.
- **Automatic Store Cleanup**: `nh clean` removes generations older than 14 days and the store is optimised, weekly.
- **Machine-Specific Configuration**: User identity and corporate root certificates are git-ignored files next to the flake, so `flake.lock` is committed and shared between machines.

---

## 📁 Repository Structure

The flake follows the [dendritic pattern](https://github.com/mightyiam/dendritic): every file under `modules/` is a [flake-parts](https://flake.parts) module, imported by [import-tree](https://github.com/denful/import-tree), and holds one feature. A feature contributes NixOS or Home Manager modules to `flake.modules.<class>.<name>`; importing one of them enables the feature.

| Path | Purpose |
| :--- | :--- |
| `flake.nix` | Inputs, and `import-tree ./modules`. |
| `modules/hosts/workstation.nix` | The host (`nixosConfigurations.nixos`): the WSL platform of `nixos-roles`, the certificates, the main user, `overlays.default`. |
| `modules/users/main-user.nix` | The main user: their roles (NixOS), their git identity and the Home Manager features they import. |
| `modules/machine/` | `machine.mainUser` and `machine.additionalTrusts`, read from the git-ignored files; the certificates. |
| `modules/editor/revim.nix` | revim in place of LazyVim, and its overlay. |
| `modules/theme/catppuccin.nix` | The Catppuccin theme (Starship, Zellij, revim). |
| `modules/terminal/zellij.nix` | Zellij started from zsh, with a guard against WSL's hidden login session. |
| `modules/ai/claude-code.nix` | Claude Code. |
| `modules/packages/` | Package fixes, as overlays (`azure-cli`). |
| `modules/flake/` | Flake plumbing: systems, `overlays.default`, formatter. |
| `exemple_profile.nix` | Example of the git-ignored `mainUser.nix`. |

Packages are distributed through overlays: each feature contributes `overlays.<name>`, `overlays.default` composes them, and the host applies it. Packages are adapted with `.override` first, then `.overrideAttrs`, and only built from scratch with `callPackage` when needed.

---

## 🚀 Getting Started

### Prerequisites

1. **Windows 10/11** with WSL2 enabled.
2. A **NixOS WSL** distribution installed (e.g. from [NixOS-WSL releases](https://github.com/nix-community/NixOS-WSL/releases)).
3. A patched **Nerd Font** installed on Windows (e.g. *JetBrains Mono Nerd Font*) for terminal icons and powerline glyphs.

---

### Step 1: Clone / Copy this Configuration

Clone or copy this repository to `/etc/nixos/`:

```bash
sudo git clone <repo-url> /etc/nixos
# or copy your existing files to /etc/nixos/
cd /etc/nixos
```

The `nixos-roles` input points to the NixOs-Opinionated modules, pinned by the committed `flake.lock`. To work on the modules from a local checkout, override it for a build: `nh os switch -- --override-input nixos-roles path:/path/to/NixOs-Opinionated`.

---

### Step 2: Configure the Machine-Specific Files

The user identity and the optional certificates live next to `flake.nix`, but are git-ignored: `flake.lock` stays shareable between machines and never records them.

1. Create `/etc/nixos/mainUser.nix` based on `exemple_profile.nix`:
   ```nix
   {
     username = "<your-username>";
     gitUserName = "Your Name";
     gitUserEmail = "your.email@example.com";
     # homeDirectory = "/home/<your-username>";  # optional
   }
   ```

2. *(Optional)* If your environment requires custom corporate root certificates, place them at:
   ```
   /etc/nixos/additional-trusts.crt
   ```

---

### Step 3: Bootstrap the System

Build and activate the flake configuration for the first time:

```bash
sudo nixos-rebuild boot --extra-experimental-features "nix-command flakes" --flake path:/etc/nixos#nixos
```

The `path:` prefix is required: a plain `/etc/nixos` reference is read as a git repository, which hides the git-ignored files above.

---

### Step 4: Restart the WSL Instance

To ensure all systemd services, users, and default shells are cleanly loaded, restart the WSL container from **PowerShell / Command Prompt** in Windows:

```powershell
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOs
wsl --shutdown
```

Then start NixOS again:

```powershell
wsl -d NixOS
```

You should now log in directly into your user account with Zsh, Starship prompt, and all tools available.

---

## 🔄 Managing and Updating the System

### Rebuilding After Changes

When you make changes to files in `/etc/nixos/`, including `mainUser.nix`:

```bash
nh os switch
```

`nh` uses `NH_FLAKE=path:/etc/nixos`, set by the configuration. With `nixos-rebuild`, the `path:` reference must be given explicitly:

```bash
sudo nixos-rebuild switch --flake path:/etc/nixos#nixos
```

### Updating Flake Inputs

To update all flake inputs (`nixpkgs`, `nixos-roles` and its own inputs such as `home-manager`, `nixos-wsl`, `catppuccin`, `revim`) to their latest versions, then commit the resulting `flake.lock`:

```bash
cd /etc/nixos
nix flake update
nh os switch
git commit flake.lock -m "chore: update flake inputs"
```

### Customising

Add a feature as a new file under `modules/`, contributing a module, and import it where it belongs. For instance, a Home Manager feature imported by the main user:

```nix
# modules/dev/go.nix
{
  flake.modules.homeManager.go =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.go pkgs.gopls ];
    };
}
```

then add `go` to the `imports` of `flake.modules.homeManager.main-user` in `modules/users/main-user.nix`. Role options of NixOs-Opinionated (`roles.<role>.*`) are set there too.

---

## 🛠️ Key Aliases & Utilities

| Command | Alias / Tool | Description |
| :--- | :--- | :--- |
| `ls` | `eza` | Modern replacement for `ls` |
| `ll` | `eza -l --git` | Long listing with Git status |
| `la` | `eza -la --git` | List all including hidden files |
| `lt` | `eza --tree --level=2` | Tree directory listing |
| `cat` | `bat --paging=never` | Syntax-highlighted file viewer |
| `zellij` | `zellij` | Terminal workspace / multiplexer |
| `fzf` | `fzf` | Interactive fuzzy finder |
| `nh` | `nh` | Nix CLI companion / helper |
| `nvim` | revim | Neovim from revim, also reachable as `vi` / `vim` |
| `direnv allow` | `direnv` | Trust the current directory's `.envrc` so it loads on `cd` |
| `idea` | JetBrains IDEA | Pre-configured with custom JetBrains plugins |
| `claude` | Claude Code | AI coding assistant |

---

## 🧭 Working with direnv

`direnv` is enabled with the `nix-direnv` integration. In any project directory:

```bash
echo "use flake" > .envrc   # or: echo "use nix" > .envrc
direnv allow
```

Entering the directory then loads the project's dev shell automatically, and the Starship prompt shows a leaf glyph with the current state (loaded / not loaded, plus a lock when the `.envrc` is not allowed yet). `nix-direnv` caches the evaluated shell and registers it as a GC root, so subsequent entries are instant and the closure survives `nix-collect-garbage`.

---

## ✏️ Working with revim

[revim](https://github.com/maximeq95/revim) replaces the LazyVim of the `base` role (both ship `nvim`): Neovim built with nixvim, with yazi and zellij around it. Its package comes from its overlay, its settings from `programs.revim` in `modules/editor/revim.nix`:

- it follows the Catppuccin flavor of the home;
- the clipboard goes through `wl-copy` (WSLg), since Windows binaries are kept off the `PATH`;
- `nixd` completes the NixOS and Home Manager options of the flake being edited, wherever it is cloned.

To go back to LazyVim, remove `revim` from the imports of the main user.

---

## 📄 License

This configuration is distributed under the terms defined in the [LICENSE](LICENSE) file.
