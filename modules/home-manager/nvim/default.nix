{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.scarisey.nvim;
in {
  options.scarisey.nvim.enable = lib.mkEnableOption "Enable Nvim default config.";
  config = lib.mkIf cfg.enable {
    #nvim
    home.shellAliases.cleanNvim = ''
      rm -Rf ~/.local/share/nvim
      rm -Rf ~/.local/state/nvim
      rm -Rf ~/.cache/nvim
    '';
    # ─── NEOVIM ─────────────────────────────────────────────────
    programs.neovim = {
      enable = true;
      defaultEditor = true; # EDITOR=nvim dans l'environnement
      viAlias = true; # vi → nvim
      vimAlias = true; # vim → nvim

      # ── nvim-treesitter via nixpkgs (parsers pré-compilés) ────
      #
      # Neovim est wrappé par Nix avec un environnement LuaJIT isolé.
      # Quand lazy installe nvim-treesitter dans ~/.local/share/nvim/lazy/,
      # ce chemin est inconnu de cet environnement → "module not found".
      # La solution : passer par programs.neovim.plugins, qui injecte
      # le plugin directement dans le runtimepath du wrapper Nix.
      #
      # Les parsers listés ici sont des .so pré-compilés dans le store Nix.
      # Zéro compilation au démarrage, zéro besoin de :TSUpdate.
      plugins = with pkgs.vimPlugins; [
        # mini.icons : requis par which-key v3+ pour l'affichage des icônes
        mini-nvim

        (nvim-treesitter.withPlugins (p:
          with p; [
            # Langages utilisés dans init.lua
            lua
            vim
            vimdoc
            javascript
            typescript
            tsx
            python
            rust
            go
            c
            cpp
            json
            yaml
            toml
            html
            css
            markdown
            markdown_inline
            bash # requis par noice pour le highlighting cmdline
            regex # requis par noice pour le highlighting cmdline
            # Bonus utiles
            nix
            dockerfile
            sql
            graphql
          ]))
      ];

      # Variables d'environnement injectées dans l'env de Neovim
      # (utile pour que Mason trouve les binaires Nix dans son PATH)
      extraPackages = with pkgs; [
        # ── Recherche (Telescope live_grep + Spectre) ──────────
        ripgrep # rg  — requis par telescope live_grep et spectre
        fd # fd  — find_files plus rapide que find
        fzf # fzf — telescope-fzf-native en a besoin au runtime

        # ── Compilation native ─────────────────────────────────
        # telescope-fzf-native : build = "make"  (lazy l'appelle au premier lancement)
        # nvim-treesitter      : parsers pré-compilés via plugins =, gcc non nécessaire
        gcc
        gnumake

        # ── Git (gitsigns, lazy.nvim bootstrap) ───────────────
        git

        # ── LSP / Mason runtime deps ───────────────────────────
        # Mason télécharge les binaires LSP ; il a besoin de ces runtimes
        # pour les installer et les exécuter.

        # Node.js → ts_ls, pyright, cssls, html, jsonls, eslint
        nodejs_20
        nodePackages.npm # certains serveurs LSP s'installent via npm

        # Python → pyright, ruff-lsp
        # Sur Nix, pip ne s'expose pas via python3Packages.pip directement :
        # il faut construire un interpréteur qui l'embarque.
        (python3.withPackages (ps:
          with ps; [
            pip
            virtualenv # Mason crée des venvs pour certains outils Python
          ]))

        # Go → gopls
        go

        # Rust → rust-analyzer
        # On utilise rustup pour que Mason puisse gérer les toolchains
        rustup

        # ── Utilitaires système (Mason downloader) ─────────────
        unzip # Mason décompresse des archives .zip
        curl # Mason télécharge via curl
        wget # fallback de curl
        gnutar # archives .tar.gz
        gzip

        # ── Outils divers ──────────────────────────────────────
        tree-sitter # CLI tree-sitter (parsers custom)
        shellcheck # LSP bash (bashls)
        stylua # formatter Lua (utilisé par lua_ls)
        nodePackages.prettier # formatter JS/TS/HTML/CSS/JSON
        black # formatter Python
        isort # imports Python
        gofumpt # formatter Go
      ];
    };

    # ─── CONFIGURATION ──────────────────────────────────────────
    xdg.configFile."nvim/init.lua" = {
      source = ../nvim/init.lua; # ← ton fichier init.lua
    };

    # ─── VARIABLES D'ENVIRONNEMENT ──────────────────────────────
    # S'assure que les binaires installés via Nix sont trouvables
    # par Mason et les LSP même hors du shell interactif
    home.sessionVariables = {
      CARGO_HOME = "${config.home.homeDirectory}/.cargo";
      GOPATH = "${config.home.homeDirectory}/go";
      GOROOT = "${pkgs.go}/share/go";
      # PATH étendu pour que Mason trouve rustup/cargo au premier lancement
      PATH = lib.concatStringsSep ":" [
        "${config.home.homeDirectory}/.cargo/bin"
        "${config.home.homeDirectory}/go/bin"
        "${config.home.homeDirectory}/.local/share/nvim/mason/bin"
        "$PATH"
      ];
    };

    # ─── PACKAGES COMPLÉMENTAIRES ───────────────────────────────
    home.packages = with pkgs; [
      # Diff / merge (Telescope diff, gitsigns)
      delta # git diff amélioré
      difftastic # diff structurel

      # Outils shell souvent appelés depuis toggleterm
      bat # cat amélioré
      eza # ls amélioré
      jq # JSON query (utile avec LSP JSON)

      # Optionnel : GUI git si tu veux lancer lazygit depuis le terminal
      lazygit
    ];
  };
}
