# Claude AI Context for NixOS Dotfiles

This file provides context for Claude AI (via GitHub Copilot CLI or other AI assistants) when working with this NixOS configuration repository.

## Repository Overview

This is a **flake-based NixOS and Home Manager configuration** repository for managing multiple machines with a modular, reproducible approach.

**Owner:** scarisey (Sylvain)  
**Primary Language:** Nix  
**Configuration Type:** Flakes-based  
**Target Systems:** x86_64-linux

## Architecture

### Flake Structure

- **Main entry point:** `flake.nix`
- **Nix flakes enabled** - All builds use `nix build`, `nixos-rebuild --flake`, and `home-manager --flake`
- **Helper library:** `lib/default.nix` provides custom functions for auto-discovering hosts and users

### Key Design Patterns

1. **Auto-discovery:** The `lib/` functions automatically discover:
   - NixOS hosts from `nixos/HOSTNAME/configuration.nix`
   - Home Manager users from `home-manager/USER/SYSTEM/HOSTNAME/home.nix`

2. **Common + Specific:** Each configuration uses a `common.nix` with shared settings, plus host/user-specific files

3. **Modular:** Reusable modules in `modules/{nixos,home-manager}/`

## Directory Structure

```
├── flake.nix              # Main flake - outputs hosts, home configs, packages, modules
├── flake.lock             # Locked dependencies (nixpkgs 25.05, home-manager, etc.)
├── lib/default.nix        # Helper functions: forHosts, forUsers, lsDirs
├── nixos/
│   ├── common.nix         # Shared NixOS config (locale, users, nix settings)
│   ├── hyperion/          # Server: Docker, Immich, Samba, VPN, backups
│   └── titan/             # Workstation: Desktop environments
├── home-manager/
│   └── sylvain/           # User configurations
│       ├── common.nix     # Shared HM config with SOPS
│       └── x86_64-linux/  # Per-host user environments
├── modules/
│   ├── nixos/             # System modules (docker, kde, gnome, vpn, etc.)
│   └── home-manager/      # User modules (devtools, shell, nvim, git, etc.)
├── pkgs/                  # Custom package derivations
├── overlays/              # Nixpkgs overlays
├── templates/             # Flake templates (devshell)
├── shell.nix              # Development shell
└── nixpkgs.nix            # Nixpkgs config
```

## Current Hosts

### hyperion (Server)
- **Role:** Home server
- **Services:** Docker, Immich (photos), Audiobookshelf, Samba, VPN server, Restic backups
- **Location:** `nixos/hyperion/`

### titan (Workstation)
- **Role:** Desktop workstation
- **Desktop:** KDE Plasma (primary), GNOME, i3+Xfce available
- **Location:** `nixos/titan/`

## User Configuration

**Primary user:** `sylvain`

Home Manager configs follow structure: `home-manager/sylvain/x86_64-linux/HOSTNAME/home.nix`

Each includes `../common.nix` which imports all home-manager modules and sets up SOPS.

## Important Flake Inputs

| Input | Purpose | Version |
|-------|---------|---------|
| `nixpkgs` | Main package source | nixos-25.05 |
| `nixpkgs-master` | Bleeding edge packages | master |
| `home-manager` | User environment | release-25.05 |
| `sops-nix` | Secrets management | Latest |
| `android-nixpkgs` | Android SDK | Latest |
| `ghostty` | Terminal emulator | Latest |
| `nixgl` | OpenGL for non-NixOS | Latest |
| `copilot-cli` | GitHub Copilot CLI | scarisey's flake |
| `homelab-nix` | Homelab modules | scarisey's repo |
| `private-vault` | Encrypted secrets | Private repo |
| `private-modules` | Private modules | Private repo |

## Key Technologies

- **Secrets:** SOPS with age encryption (`~/.config/sops/age/keys.txt`)
- **Shell:** Zsh with Starship prompt
- **Editors:** Neovim (primary), Vim
- **Terminal:** Ghostty, WezTerm
- **Multiplexer:** Tmux
- **Containers:** Docker, Distrobox, Podman
- **Virtualization:** QEMU/KVM, libvirtd, Quickemu
- **Backups:** Restic

## Custom Modules

### NixOS Modules (`modules/nixos/`)
- `bootanimation.nix` - Plymouth boot splash
- `docker.nix` - Docker daemon and containers
- `gnome.nix`, `kde.nix`, `i3.nix` - Desktop environments
- `vpn.nix` - VPN client configuration
- `qemu.nix` - Virtualization support
- `network.nix` - Network settings

### Home Manager Modules (`modules/home-manager/`)
- `devtools.nix` - IDEs, compilers, dev tools
- `myshell.nix` - Zsh, Starship, shell utilities
- `git/` - Git config (includes private config via SOPS)
- `nvim/` - Neovim configuration
- `ssh/` - SSH config with private hosts via SOPS
- `tmux/` - Tmux configuration
- `android.nix` - Android Studio and SDK
- `gui.nix` - GUI applications (browsers, media players)
- `autoUpdate.nix` - Auto-update services

## Custom Packages (`pkgs/`)

Custom derivations for tools not in nixpkgs or with specific versions:
- `adoc` - AsciiDoc tools
- `antora` - Documentation generator
- `glab-tools` - GitLab CLI utilities
- `graalvm-21` - GraalVM JDK 21
- `msgconvert` - Email message converter
- And others...

## Common Commands

### Building

```bash
# NixOS system
sudo nixos-rebuild switch --flake .#hostname

# Home Manager
home-manager switch --flake .
# or
nix run . -- switch --flake .

# Check flake
nix flake check

# Update inputs
nix flake update

# Build specific output
nix build .#nixosConfigurations.hyperion.config.system.build.toplevel
```

### Development

```bash
# Enter dev shell (enables flakes)
nix-shell

# Format code
nix fmt

# List flake outputs
nix flake show

# Build custom package
nix build .#packages.x86_64-linux.adoc
```

### SOPS Secrets

```bash
# Edit secrets
sops secrets.yaml

# Update keys after adding new host
sops updatekeys secrets.yaml

# View current secrets (requires age key)
sops -d secrets.yaml
```

## Configuration Patterns

### Adding a New NixOS Host

1. Create `nixos/HOSTNAME/` directory
2. Add `configuration.nix` that imports `../common.nix`
3. Add `hardware.nix` (generate with `nixos-generate-config`)
4. Build with `sudo nixos-rebuild switch --flake .#HOSTNAME`

The `lib/default.nix` `forHosts` function auto-discovers it.

### Adding Home Manager Config for New Host

1. Create `home-manager/sylvain/x86_64-linux/HOSTNAME/`
2. Add `home.nix` that imports `../../common.nix`
3. Build with `home-manager switch --flake .`

The `lib/default.nix` `forUsers` function auto-discovers it.

### Adding a New Module

**NixOS module:**
1. Create `modules/nixos/mymodule.nix`
2. Export in `modules/nixos/default.nix`
3. Import in `nixos/common.nix` or specific host

**Home Manager module:**
1. Create `modules/home-manager/mymodule.nix`
2. Export in `modules/home-manager/default.nix`
3. Automatically imported via `builtins.attrValues outputs.homeManagerModules` in user's `common.nix`

## Important Files to Check

When making changes, commonly edited files:

- `flake.nix` - Add/update inputs, modify outputs
- `nixos/common.nix` - System-wide NixOS settings
- `home-manager/sylvain/common.nix` - User-wide HM settings
- `modules/` - Modular functionality
- `overlays/default.nix` - Package overrides

## Binary Caches

Pre-configured caches in `flake.nix` `nixConfig`:
- `ghostty.cachix.org` - Ghostty terminal builds
- `nix-community.cachix.org` - Community packages
- `scarisey-public.cachix.org` - Personal public cache

These speed up builds by providing pre-built binaries.

## Coding Conventions

1. **Formatting:** Use `alejandra` formatter (via `nix fmt`)
2. **Imports:** Group and organize - system imports, then paths
3. **Options:** Use `mkEnableOption`, `mkOption` with types for modules
4. **Comments:** Minimal, prefer self-documenting code
5. **Secrets:** Never commit secrets, always use SOPS
6. **Naming:** `kebab-case` for files, `camelCase` for Nix attributes

## Private Dependencies

This repo references private repositories:
- `private-vault` (github:scarisey/vault) - SOPS encrypted secrets
- `private-modules` (github:scarisey/private-nix-modules) - Private modules

When forking, either:
1. Create your own private repos with same structure
2. Remove these inputs and related imports

## Troubleshooting Tips

### Flake issues
- Ensure flakes enabled: `experimental-features = nix-command flakes` in nix config
- Use `nix-shell` (loads `shell.nix` which enables flakes)

### SOPS issues
- Age key must exist at `~/.config/sops/age/keys.txt`
- Public key must be in `.sops.yaml` of vault repo
- Run `sops updatekeys` after modifying `.sops.yaml`

### Build failures
- Check with `nix flake check`
- Update inputs: `nix flake update`
- Clear cache: `nix-collect-garbage -d`

### Private repo access
- Need GitHub PAT in `~/.config/nix/nix.conf`:
  ```
  access-tokens = github.com=ghp_xxxxx
  ```

## System Information

- **Timezone:** Europe/Paris
- **Locale:** fr_FR.UTF-8
- **Keyboard:** French (fr)
- **User:** sylvain (member of: wheel, docker, libvirtd, kvm, networkmanager)
- **Shell:** zsh

## AI Assistant Guidelines

When helping with this repository:

1. **Respect the flake structure** - Don't suggest non-flake commands
2. **Use auto-discovery** - New hosts/users follow the directory pattern
3. **Keep modules modular** - Don't put everything in one file
4. **Check private deps** - Be aware some imports reference private repos
5. **Format with alejandra** - Run `nix fmt` after changes
6. **Test locally first** - Use `nixos-rebuild test` or `home-manager build`
7. **Preserve existing style** - Match the coding conventions used
8. **Handle secrets properly** - Use SOPS, never plain text
9. **Consider both NixOS and non-NixOS** - Home Manager works on both

## Version Information

- **NixOS:** 25.05 (from nixpkgs input)
- **Home Manager:** release-25.05
- **State Version:** 23.05 (home), varies per host (system)

## Links

- **Repository:** https://github.com/scarisey/nixos-dotfiles
- **NixOS Manual:** https://nixos.org/manual/nixos/stable/
- **Home Manager Manual:** https://nix-community.github.io/home-manager/
- **Nix Flakes:** https://nixos.wiki/wiki/Flakes

---

**Last Updated:** 2025-10-15  
**Maintainer:** Sylvain Carisey (scarisey)
