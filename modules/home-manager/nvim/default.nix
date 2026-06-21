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
      rm -rf ~/.local/share/nvim/lazy
      rm -rf ~/.local/share/nvim/mason
      rm -rf ~/.local/state/nvim
      rm -rf ~/.cache/nvim
    '';
    # ─── NEOVIM ─────────────────────────────────────────────────
    programs.neovim = {
      enable = true;
      defaultEditor = true; # EDITOR=nvim dans l'environnement
      viAlias = true; # vi → nvim

      plugins = with pkgs.vimPlugins; [
        # mini.icons : requis par which-key v3+ pour l'affichage des icônes
        mini-nvim
        nvim-treesitter.withAllGrammars
      ];

      extraPackages = with pkgs; [
        # ── Recherche (snacks.picker grep + Spectre) ───────────
        ripgrep # rg  — requis par snacks.picker grep et spectre
        fd # fd  — requis par snacks.picker files

        # ── Compilation native ─────────────────────────────────
        # nvim-treesitter : parsers pré-compilés via plugins =, gcc non nécessaire
        gcc
        gnumake

        # ── Git (gitsigns, lazy.nvim bootstrap) ───────────────
        git

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
        prettier # formatter JS/TS/HTML/CSS/JSON
        black # formatter Python
        isort # imports Python
        gofumpt # formatter Go
      ];
      extraPython3Packages = ps: with ps; [ pynvim ];
      withRuby = true;
      withPython3 = true;
      withNodeJs = true;
      extraConfig = ''
        let g:loaded_perl_provider = 0
      '';
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
      # Diff / merge (snacks.picker diff, gitsigns)
      delta # git diff amélioré
      difftastic # diff structurel

      # Outils shell souvent appelés depuis snacks.terminal
      bat # cat amélioré
      eza # ls amélioré
      jq # JSON query (utile avec LSP JSON)

      # Optionnel : GUI git si tu veux lancer lazygit depuis le terminal
      lazygit
    ];
  };
}
