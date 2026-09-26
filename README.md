# NixOS WSL Development Environment Configuration

A reproducible, declarative NixOS configuration for WSL (Windows Subsystem for Linux) powered by **Nix Flakes** and **Home Manager**.

This project bootstraps and manages a fully-configured developer environment on Windows WSL, complete with modern CLI utilities, shell optimizations, cloud/DevOps tooling, and declarative IDE configurations.

---

## 🌟 What This Project Does

- **Declarative NixOS on WSL**: Leverages [`NixOS-WSL`](https://github.com/nix-community/NixOS-WSL) for lightweight, high-performance Linux on Windows without the overhead of standard virtualization.
- **Home Manager Integration**: Declaratively manages user profiles, dotfiles, and user packages.
- **Modern Shell & Terminal**:
  - **Zsh** with Oh-My-Zsh plugins (`git`, `ssh`, `kubectl`, `azure`, `terraform`, `kubectx`, `helm`, `ansible`).
  - **Starship Prompt**: Custom Catppuccin Mocha powerline theme with JetBrains Mono Nerd Font glyphs.
  - **Zellij**: Modern terminal multiplexer pre-configured with Zsh integration.
  - **Modern CLI Replacements**: `eza` (for `ls`), `bat` (for `cat`), `ripgrep` (`rg`), `fd`, `fzf`, `jq`, `up`, `lazyssh`.
- **Development & IDE**:
  - **IntelliJ IDEA**: Declaratively provisioned with custom plugins via `nix-jetbrains-plugins` (File Watcher, Junie, MCP Server, ML LLM, ACP).
  - **GitHub Copilot CLI** & development toolchains.
  - **Nix Tooling**: `nixfmt` code formatter and `nh` helper.
- **Cloud & DevOps Ready**: Preloaded with `azure-cli`, `kubectl`, `helm`, `fluxcd`, `terraform`, and `ansible`.
- **Modular User Configuration**: Keeps user identities and corporate root certificates separated in `/etc/nixos-config/`.

---

## 📁 Repository Structure

| File | Purpose |
| :--- | :--- |
| `flake.nix` | Flake entry point defining inputs, NixOS system configuration, WSL settings, and Home Manager modules. |
| `home_base.nix` | Reusable Home Manager module configuring user packages, shell (Zsh + Starship), Git, Zellij, and IDE setup. |
| `system-config.nix` | System-level NixOS state version settings. |
| `system-customisation.nix` | System customizations: time zone, unfree package whitelisting, Nerd Fonts, Nix experimental features (`flakes`, `nix-command`), and default shell. |
| `wsl-base-config.nix` | Base WSL configurations (WSL enablement, Windows driver interop, path isolation). |
| `exemple_profile.nix` | Example profile template for defining user identity (`username`, `gitUserName`, `gitUserEmail`). |

---

## 🚀 Getting Started

### Prerequisites

1. **Windows 10/11** with WSL2 enabled.
2. A **NixOS WSL** distribution installed (e.g. from [NixOS-WSL releases](https://github.com/nix-community/NixOS-WSL/releases)).
3. A patched **Nerd Font** installed on Windows (e.g. *JetBrains Mono Nerd Font*) for terminal icons and powerline glyphs.

---

### Step 1: Configure User Profile

The flake expects your user profile configuration to be located at `/etc/nixos-config/mainUser.nix`.

1. Create the configuration directory:
   ```bash
   sudo mkdir -p /etc/nixos-config
   ```

2. Create `/etc/nixos-config/mainUser.nix` based on `exemple_profile.nix`:
   ```nix
   {
     username = "<your-username>";
     gitUserName = "Your Name";
     gitUserEmail = "your.email@example.com";
   }
   ```

3. *(Optional)* If your environment requires custom corporate root certificates, place them at:
   ```
   /etc/nixos-config/additional-trusts.crt
   ```

---

### Step 2: Clone / Copy this Configuration

Clone or copy this repository to `/etc/nixos/`:

```bash
sudo git clone <repo-url> /etc/nixos
# or copy your existing files to /etc/nixos/
cd /etc/nixos
```

---

### Step 3: Bootstrap the System

Build and activate the flake configuration for the first time:

```bash
sudo nixos-rebuild boot --extra-experimental-features "nix-command flakes" --flake .#nixos
```

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

When you make changes to files in `/etc/nixos/` or your user profile:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

Or using the installed `nh` helper:

```bash
nh os switch /etc/nixos
```

### Updating Flake Inputs

To update all flake inputs (such as `nixpkgs`, `home-manager`, `nixos-wsl`) to their latest versions:

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

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
| `idea` | JetBrains IDEA | Pre-configured with custom JetBrains plugins |

---

## 📄 License

This configuration is distributed under the terms defined in the [LICENSE](LICENSE) file.
