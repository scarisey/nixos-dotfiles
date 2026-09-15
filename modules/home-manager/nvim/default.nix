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

        # Rust → rust-analyzer, cargo, rustc, clippy, rustfmt fournis
        # directement par nixpkgs.
        #
        # On n'utilise PLUS `rustup` : ses toolchains sont téléchargées puis
        # patchées (patchelf) contre le glibc du nixpkgs courant au moment de
        # `rustup toolchain install`. Ce lien est figé dans le temps ; dès
        # que nixpkgs met à jour glibc et que l'ancienne version est
        # garbage-collectée du store, les binaires cargo/rustc installés
        # deviennent des liens morts ("No such file or directory" alors que
        # le fichier existe : c'est son interpréteur ELF qui pointe vers un
        # chemin disparu) — vécu en conditions réelles avec rustaceanvim
        # (`cargo metadata` en échec). cargo/rustc en paquets Nix classiques
        # n'ont pas ce problème : ce sont de vraies dérivations, jamais
        # patchées a posteriori, donc jamais cassées par un GC de glibc.
        cargo
        rustc
        clippy
        rustfmt

        # Rust → débogueur (codelldb, package dédié fourni par nixpkgs qui
        # expose un binaire `codelldb` autonome sur le PATH). rustaceanvim
        # détecte automatiquement `codelldb` sur le PATH, pas besoin de le
        # télécharger via Mason ni de le configurer manuellement.
        vscode-extensions.vadimcn.vscode-lldb.adapter

        # ── Utilitaires système (Mason downloader) ─────────────
        unzip # Mason décompresse des archives .zip
        curl # Mason télécharge via curl
        wget # fallback de curl
        gnutar # archives .tar.gz
        gzip

        # Nix → nil (LSP), fourni directement par Nix : le paquet Mason
        # "nil" s'installe via `cargo install`, or seul `rustup` est
        # présent sur le PATH (sans toolchain par défaut), donc `cargo`
        # est introuvable et l'installation Mason échoue
        # (voir "nil_ls" retiré de ensure_installed dans init.lua).
        nil

        # ── Outils divers ──────────────────────────────────────
        tree-sitter # CLI tree-sitter (parsers custom)
        shellcheck # LSP bash (bashls)
        stylua # formatter Lua (utilisé par lua_ls)
        prettier # formatter JS/TS/HTML/CSS/JSON
        black # formatter Python
        isort # imports Python
        gofumpt # formatter Go
      ];
      extraPython3Packages = ps: with ps; [pynvim];
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
      # PATH étendu pour que Mason/rustaceanvim trouvent cargo au premier lancement
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
