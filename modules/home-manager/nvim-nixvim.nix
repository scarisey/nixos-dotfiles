# Configuration Neovim déclarative via nixvim (https://github.com/nix-community/nixvim).
#
# Remplace progressivement le module `nvim/` historique (lazy.nvim + Mason) :
#   - Plus de Mason : chaque LSP/outil est un paquet Nix (`plugins.lsp.servers.<x>.enable`),
#     donc plus de dépendance à `cargo`/`npm`/réseau au runtime pour les installer.
#   - Plus de lazy.nvim : nixvim génère et charge lui-même le runtime Neovim,
#     donc plus de désynchronisation possible entre le packpath Nix et l'init.lua
#     (c'est exactement le bug treesitter/Comment.nvim rencontré avec le module DIY).
#   - Les bouts de logique trop dynamiques pour être déclaratifs (thème
#     jour/nuit avec watcher de fichier, transparence à chaud) restent en Lua
#     via `extraConfigLua`, échappatoire volontaire de nixvim.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.scarisey.nvim-nixvim;
in {
  options.scarisey.nvim-nixvim.enable = lib.mkEnableOption "Enable Nvim config (nixvim, déclaratif, sans Mason/lazy.nvim).";

  imports = [inputs.nixvim.homeManagerModules.nixvim];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.scarisey.nvim.enable;
        message = ''
          scarisey.nvim (ancien module lazy.nvim/Mason) et scarisey.nvim-nixvim
          (nouveau module déclaratif) sont mutuellement exclusifs : activez
          l'un ou l'autre, pas les deux (ils fourniraient chacun leur propre
          binaire `nvim`).
        '';
      }
    ];

    home.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      # Plus de dossiers lazy/mason à nettoyer : tout est dans le store Nix.
      cleanNvim = ''
        rm -rf ~/.local/state/nvim
        rm -rf ~/.cache/nvim
      '';
    };

    # Variables d'environnement pour les projets Rust/Go en dehors de nvim
    # (rust-analyzer lui-même est fourni par Nix via la dépendance de
    # rustaceanvim, ceci ne sert qu'aux commandes cargo/go interactives).
    home.sessionVariables = {
      CARGO_HOME = "${config.home.homeDirectory}/.cargo";
      GOPATH = "${config.home.homeDirectory}/go";
      GOROOT = "${pkgs.go}/share/go";
      PATH = lib.concatStringsSep ":" [
        "${config.home.homeDirectory}/.cargo/bin"
        "${config.home.homeDirectory}/go/bin"
        "$PATH"
      ];
    };

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      # nixpkgs est suivi via `inputs.nixvim.inputs.nixpkgs.follows` (voir
      # flake.nix) : le nixpkgs réellement utilisé est donc bien celui du
      # repo, malgré l'avertissement de version que nixvim affiche sinon.
      version.enableNixpkgsReleaseCheck = false;

      # ── Providers ──────────────────────────────────────────
      extraPython3Packages = ps: [ps.pynvim];

      # ── Paquets système (fournis par Nix, plus de Mason) ────
      extraPackages = with pkgs; [
        ripgrep # requis par snacks.picker grep et spectre
        fd # requis par snacks.picker files
        git # gitsigns / snacks git pickers

        # Rust : cargo/rustc/clippy/rustfmt fournis directement par nixpkgs
        # (rust-analyzer est tiré automatiquement en dépendance de
        # rustaceanvim, voir plugins.rustaceanvim ci-dessous).
        #
        # On n'utilise PLUS `rustup` : ses toolchains sont téléchargées puis
        # patchées (patchelf) contre le glibc du nixpkgs courant au moment de
        # `rustup toolchain install`. Ce lien est figé dans le temps ; dès
        # que nixpkgs (rolling/unstable) met à jour glibc et que l'ancienne
        # version est garbage-collectée du store, les binaires cargo/rustc
        # installés deviennent des liens morts ("No such file or directory"
        # alors que le fichier existe : c'est son interpréteur ELF qui pointe
        # vers un chemin disparu). C'est exactement l'erreur rencontrée avec
        # rustaceanvim (`cargo metadata` en échec). cargo/rustc en paquets
        # Nix classiques n'ont pas ce problème : ce sont de vraies
        # dérivations, jamais patchées a posteriori, donc jamais cassées par
        # un GC de glibc.
        #
        # Contrepartie assumée : plus de gestion multi-toolchain par projet
        # (rust-toolchain.toml, nightly, etc.) — un seul toolchain stable,
        # celui de nixpkgs, pour tous les projets Rust.
        cargo
        rustc
        clippy
        rustfmt
        vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb, détecté sur PATH par rustaceanvim

        go # gopls tiré automatiquement par plugins.lsp.servers.gopls

        # Formatters (pas de LSP dédié dans nixvim pour ces cas)
        stylua
        prettier
        black
        isort
        gofumpt
      ];

      # ── Globals (vim.g.*) ────────────────────────────────────
      globals = {
        mapleader = " ";
        maplocalleader = " ";
        loaded_perl_provider = 0;
      };

      # ── Options générales (vim.opt.*) ────────────────────────
      opts = {
        number = true;
        relativenumber = false;
        cursorline = true;
        signcolumn = "yes";
        colorcolumn = "";
        termguicolors = true;
        showmode = false;
        laststatus = 3;
        cmdheight = 0;
        pumheight = 10;
        winblend = 0;
        pumblend = 0;

        tabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        smartindent = true;
        wrap = false;
        linebreak = true;
        scrolloff = 8;
        sidescrolloff = 8;
        splitbelow = true;
        splitright = true;
        virtualedit = "block";

        ignorecase = true;
        smartcase = true;
        hlsearch = true;
        incsearch = true;

        updatetime = 200;
        timeoutlen = 300;
        undofile = true;
        backup = false;
        swapfile = false;
        clipboard = "unnamedplus";
        confirm = true;

        completeopt = ["menu" "menuone" "noselect"];
      };

      # ── Diagnostics visuels ──────────────────────────────────
      diagnostic.settings = {
        virtual_text = {
          prefix = "●";
          spacing = 4;
        };
        signs = true;
        underline = true;
        update_in_insert = false;
        severity_sort = true;
        float = {
          border = "rounded";
          source = "always";
        };
      };

      # ── Raccourcis globaux (hors LSP, calqués sur Zed) ───────
      keymaps = [
        # Fenêtres
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w>h";
          options.desc = "Window left";
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w>j";
          options.desc = "Window down";
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w>k";
          options.desc = "Window up";
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w>l";
          options.desc = "Window right";
        }
        # Redimensionner
        {
          mode = "n";
          key = "<C-Up>";
          action = "<cmd>resize +2<cr>";
          options.desc = "Resize up";
        }
        {
          mode = "n";
          key = "<C-Down>";
          action = "<cmd>resize -2<cr>";
          options.desc = "Resize down";
        }
        {
          mode = "n";
          key = "<C-Left>";
          action = "<cmd>vertical resize -2<cr>";
          options.desc = "Resize left";
        }
        {
          mode = "n";
          key = "<C-Right>";
          action = "<cmd>vertical resize +2<cr>";
          options.desc = "Resize right";
        }
        # Buffers
        {
          mode = "n";
          key = "<S-l>";
          action = "<cmd>bnext<cr>";
          options.desc = "Next buffer";
        }
        {
          mode = "n";
          key = "<S-h>";
          action = "<cmd>bprevious<cr>";
          options.desc = "Prev buffer";
        }
        {
          mode = "n";
          key = "<leader>bo";
          action = "<cmd>%bd|e#|bd#<cr>";
          options.desc = "Close other buffers";
        }
        # Fichier alternatif
        {
          mode = "n";
          key = "<C-6>";
          action = "<C-^>";
          options.desc = "Alternate file";
        }
        # Annuler le surlignage de recherche
        {
          mode = "n";
          key = "<esc>";
          action = "<cmd>nohl<cr><esc>";
          options.desc = "Clear search highlight";
        }
        # Indentation en Visual sans quitter le mode
        {
          mode = "v";
          key = "<";
          action = "<gv";
          options.desc = "Indent left";
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
          options.desc = "Indent right";
        }
        # Déplacer les lignes
        {
          mode = "n";
          key = "<A-j>";
          action = "<cmd>m .+1<cr>==";
          options.desc = "Move line down";
        }
        {
          mode = "n";
          key = "<A-k>";
          action = "<cmd>m .-2<cr>==";
          options.desc = "Move line up";
        }
        {
          mode = "v";
          key = "<A-j>";
          action = ":m '>+1<cr>gv=gv";
          options.desc = "Move selection down";
        }
        {
          mode = "v";
          key = "<A-k>";
          action = ":m '<-2<cr>gv=gv";
          options.desc = "Move selection up";
        }
        # Coller sans remplacer le registre
        {
          mode = "v";
          key = "p";
          action = ''"_dP'';
          options.desc = "Paste without yanking";
        }
        # Tout sélectionner
        {
          mode = "n";
          key = "<leader>A";
          action = "ggVG";
          options.desc = "Select all";
        }
        # Sauvegarder
        {
          mode = "n";
          key = "<C-s>";
          action = "<cmd>w<cr>";
          options.desc = "Save file";
        }
        {
          mode = "i";
          key = "<C-s>";
          action = "<esc><cmd>w<cr>";
          options.desc = "Save file";
        }

        # ── Snacks : picker / terminal / git / notifier / words / misc ──
        {
          mode = "n";
          key = "<leader><space>";
          action.__raw = "function() Snacks.picker.files() end";
          options.desc = "Find files";
        }
        {
          mode = "n";
          key = "<leader>/";
          action.__raw = "function() Snacks.picker.grep() end";
          options.desc = "Project search";
        }
        {
          mode = "n";
          key = "<leader>fb";
          action.__raw = "function() Snacks.picker.buffers() end";
          options.desc = "Buffers";
        }
        {
          mode = "n";
          key = "<leader>fh";
          action.__raw = "function() Snacks.picker.help() end";
          options.desc = "Help";
        }
        {
          mode = "n";
          key = "<leader>fs";
          action.__raw = "function() Snacks.picker.lsp_symbols() end";
          options.desc = "Document symbols";
        }
        {
          mode = "n";
          key = "<leader>fS";
          action.__raw = "function() Snacks.picker.lsp_workspace_symbols() end";
          options.desc = "Workspace symbols";
        }
        {
          mode = "n";
          key = "<leader>fd";
          action.__raw = "function() Snacks.picker.diagnostics() end";
          options.desc = "Diagnostics";
        }
        {
          mode = "n";
          key = "<leader>fr";
          action.__raw = "function() Snacks.picker.recent() end";
          options.desc = "Recent files";
        }
        {
          mode = "n";
          key = "<leader>fc";
          action.__raw = "function() Snacks.picker.commands() end";
          options.desc = "Commands";
        }
        {
          mode = "n";
          key = "<leader>fw";
          action.__raw = "function() Snacks.picker.grep_word() end";
          options.desc = "Search word";
        }
        {
          mode = "n";
          key = "<leader>fg";
          action.__raw = "function() Snacks.picker.git_files() end";
          options.desc = "Git files";
        }
        {
          mode = "n";
          key = "<leader>fl";
          action.__raw = "function() Snacks.picker.lines() end";
          options.desc = "Buffer lines";
        }
        {
          mode = "n";
          key = "<leader>fk";
          action.__raw = "function() Snacks.picker.keymaps() end";
          options.desc = "Keymaps";
        }
        {
          mode = "n";
          key = "<leader>fm";
          action.__raw = "function() Snacks.picker.marks() end";
          options.desc = "Marks";
        }
        {
          mode = "n";
          key = "<leader>fu";
          action.__raw = "function() Snacks.picker.undo() end";
          options.desc = "Undo history";
        }
        {
          mode = "n";
          key = "<leader>fp";
          action.__raw = "function() Snacks.picker.resume() end";
          options.desc = "Resume picker";
        }
        {
          mode = "n";
          key = "<C-&>";
          action.__raw = ''function() Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } }) end'';
          options.desc = "Toggle terminal";
        }
        {
          mode = "n";
          key = "<leader>tt";
          action.__raw = ''function() Snacks.terminal.toggle(nil, { win = { position = "float" } }) end'';
          options.desc = "Float terminal";
        }
        {
          mode = "n";
          key = "<leader>tv";
          action.__raw = ''function() Snacks.terminal.toggle(nil, { win = { position = "right", width = 0.4 } }) end'';
          options.desc = "Vertical terminal";
        }
        {
          mode = "n";
          key = "<leader>gg";
          action.__raw = "function() Snacks.lazygit() end";
          options.desc = "LazyGit";
        }
        {
          mode = "n";
          key = "<leader>gB";
          action.__raw = "function() Snacks.gitbrowse() end";
          options.desc = "Git browse";
        }
        {
          mode = "n";
          key = "<leader>gf";
          action.__raw = "function() Snacks.lazygit.log_file() end";
          options.desc = "Lazygit file log";
        }
        {
          mode = "n";
          key = "<leader>gl";
          action.__raw = "function() Snacks.picker.git_log() end";
          options.desc = "Git log";
        }
        {
          mode = "n";
          key = "<leader>gL";
          action.__raw = "function() Snacks.picker.git_log_file() end";
          options.desc = "Git log (file)";
        }
        {
          mode = "n";
          key = "<leader>gS";
          action.__raw = "function() Snacks.picker.git_status() end";
          options.desc = "Git status";
        }
        {
          mode = "n";
          key = "<leader>gc";
          action.__raw = "function() Snacks.picker.git_branches() end";
          options.desc = "Git branches";
        }
        {
          mode = "n";
          key = "<leader>nh";
          action.__raw = "function() Snacks.notifier.show_history() end";
          options.desc = "Notification history";
        }
        {
          mode = "n";
          key = "<leader>nd";
          action.__raw = "function() Snacks.notifier.hide() end";
          options.desc = "Dismiss notifications";
        }
        {
          mode = "n";
          key = "<leader>nl";
          action.__raw = ''
            function()
              vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.expand("$HOME/.local/state/nvim")))
            end
          '';
          options.desc = "Show logs directory";
        }
        {
          mode = "n";
          key = "]]";
          action.__raw = "function() Snacks.words.jump(1, true) end";
          options.desc = "Next reference";
        }
        {
          mode = "n";
          key = "[[";
          action.__raw = "function() Snacks.words.jump(-1, true) end";
          options.desc = "Prev reference";
        }
        {
          mode = "n";
          key = "<leader>bd";
          action.__raw = "function() Snacks.bufdelete() end";
          options.desc = "Delete buffer";
        }
        {
          mode = "n";
          key = "<leader>rF";
          action.__raw = "function() Snacks.rename.rename_file() end";
          options.desc = "Rename file";
        }

        # ── Fichiers (nvim-tree) ─────────────────────────────
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>NvimTreeFindFileToggle<cr>";
          options.desc = "Toggle file tree";
        }

        # ── Recherche/remplacement (spectre) ─────────────────
        {
          mode = "n";
          key = "<leader>h";
          action = "<cmd>Spectre<cr>";
          options.desc = "Search & replace";
        }
        {
          mode = "n";
          key = "<leader>hw";
          action.__raw = "function() require('spectre').open_visual({ select_word = true }) end";
          options.desc = "Search word";
        }

        # ── DAP ───────────────────────────────────────────────
        {
          mode = "n";
          key = "<F5>";
          action.__raw = "function() require('dap').continue() end";
          options.desc = "Debug: Continue";
        }
        {
          mode = "n";
          key = "<F10>";
          action.__raw = "function() require('dap').step_over() end";
          options.desc = "Debug: Step over";
        }
        {
          mode = "n";
          key = "<F11>";
          action.__raw = "function() require('dap').step_into() end";
          options.desc = "Debug: Step into";
        }
        {
          mode = "n";
          key = "<F12>";
          action.__raw = "function() require('dap').step_out() end";
          options.desc = "Debug: Step out";
        }
        {
          mode = "n";
          key = "<leader>db";
          action.__raw = "function() require('dap').toggle_breakpoint() end";
          options.desc = "Toggle breakpoint";
        }
        {
          mode = "n";
          key = "<leader>dB";
          action.__raw = ''function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end'';
          options.desc = "Conditional breakpoint";
        }
        {
          mode = "n";
          key = "<leader>dc";
          action.__raw = "function() require('dap').continue() end";
          options.desc = "Continue";
        }
        {
          mode = "n";
          key = "<leader>dl";
          action.__raw = "function() require('dap').run_last() end";
          options.desc = "Run last";
        }
        {
          mode = "n";
          key = "<leader>dt";
          action.__raw = "function() require('dap').terminate() end";
          options.desc = "Terminate";
        }
        {
          mode = "n";
          key = "<leader>dr";
          action.__raw = "function() require('dap').repl.toggle() end";
          options.desc = "Toggle REPL";
        }
        {
          mode = "n";
          key = "<leader>du";
          action.__raw = "function() require('dapui').toggle() end";
          options.desc = "Toggle UI";
        }
      ];

      # ── Autocommandes ─────────────────────────────────────────
      autoCmd = [
        {
          event = "FileType";
          pattern = ["help" "qf" "man" "lspinfo" "checkhealth"];
          command = "nnoremap <buffer><silent> q :close<cr>";
        }
      ];

      # ── Treesitter (nativement géré par nixvim : grammars via Nix,
      # chargement natif, plus de bricolage packpath comme dans le module DIY) ──
      plugins.treesitter = {
        enable = true;
        settings.highlight.enable = true;
        settings.indent.enable = true;
      };

      # ── LSP (sans Mason : chaque serveur est un paquet Nix) ────
      plugins.lsp = {
        enable = true;
        keymaps = {
          silent = true;
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gy" = "type_definition";
            "gI" = "implementation";
            "gr" = "references";
            "gA" = "references";
            "gh" = "hover";
            "K" = "hover";
            "gH" = "signature_help";
            "g." = "code_action";
            "cd" = "rename";
          };
          diagnostic = {
            "]d" = "goto_next";
            "[d" = "goto_prev";
          };
          extra = [
            {
              key = "<C-S-i>";
              mode = ["n" "v"];
              action.__raw = "function() vim.lsp.buf.format({ async = true }) end";
              options.desc = "Format file";
            }
            {
              key = "<C-w>d";
              action.__raw = "vim.diagnostic.open_float";
              options.desc = "Show diagnostics";
            }
            {
              key = "gs";
              action.__raw = "function() Snacks.picker.lsp_symbols() end";
              options.desc = "Document symbols";
            }
            {
              key = "gS";
              action.__raw = "function() Snacks.picker.lsp_workspace_symbols() end";
              options.desc = "Workspace symbols";
            }
            {
              key = "]e";
              action.__raw = ''function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end'';
              options.desc = "Next error";
            }
            {
              key = "[e";
              action.__raw = ''function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end'';
              options.desc = "Prev error";
            }
          ];
        };
        servers = {
          lua_ls.enable = true;
          ts_ls.enable = true;
          pyright.enable = true;
          gopls.enable = true;
          cssls.enable = true;
          html.enable = true;
          jsonls.enable = true;
          nil_ls.enable = true;
          # rust_analyzer : PAS ici, géré par plugins.rustaceanvim ci-dessous
          # (les deux ne doivent jamais être actifs en même temps).
        };
      };

      # lazydev : remplace neodev (déprécié), configure lua_ls pour l'édition
      # de configs Neovim (complétion vim.*, api Neovim).
      plugins.lazydev.enable = true;

      # ── RUST : rustaceanvim gère rust-analyzer + runnables/testables/dap ──
      plugins.rustaceanvim = {
        enable = true;
        settings = {
          tools.hover_actions.auto_focus = true;
          server = {
            # Les raccourcis LSP génériques (gd, gr, K, ...) sont déjà
            # attachés globalement par plugins.lsp.keymaps via l'autocommande
            # LspAttach : ils couvrent aussi rust-analyzer sans rien dupliquer
            # ici. On n'ajoute que les raccourcis Cargo, spécifiques à Rust.
            on_attach.__raw = ''
              function(client, bufnr)
                local map = function(mode, lhs, rhs, desc)
                  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
                end
                map("n", "<leader>cr", function() vim.cmd.RustLsp("runnables") end,     "Rust: Run (runnables)")
                map("n", "<leader>ct", function() vim.cmd.RustLsp("testables") end,     "Rust: Run unit tests")
                map("n", "<leader>cd", function() vim.cmd.RustLsp("debuggables") end,   "Rust: Debug (run/tests)")
                map("n", "<leader>co", function() vim.cmd.RustLsp("openCargo") end,     "Rust: Open Cargo.toml")
                map("n", "<leader>ce", function() vim.cmd.RustLsp("explainError") end,  "Rust: Explain error")
                map("n", "<leader>cm", function() vim.cmd.RustLsp("expandMacro") end,   "Rust: Expand macro")
              end
            '';
          };
        };
      };

      # ── DEBUG (DAP) ────────────────────────────────────────────
      plugins.dap.enable = true;
      plugins.dap-ui.enable = true;
      plugins.dap-virtual-text = {
        enable = true;
        settings.commented = true;
      };

      # ── Complétion ──────────────────────────────────────────────
      plugins.cmp-nvim-lsp.enable = true;
      plugins.luasnip.enable = true;
      plugins.friendly-snippets.enable = true;
      plugins.lspkind = {
        enable = true;
        settings = {
          mode = "symbol_text";
          maxwidth = 50;
          ellipsis_char = "…";
        };
      };
      plugins.cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          sources = [
            {name = "nvim_lsp";}
            {name = "luasnip";}
            {name = "buffer";}
            {name = "path";}
          ];
          window = {
            completion.__raw = ''require('cmp').config.window.bordered({ border = "rounded" })'';
            documentation.__raw = ''require('cmp').config.window.bordered({ border = "rounded" })'';
          };
          mapping = {
            "<Tab>".__raw = ''
              cmp.mapping(function(fallback)
                local cmp = require('cmp')
                local luasnip = require('luasnip')
                if cmp.visible() then cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                else fallback() end
              end, { "i", "s" })
            '';
            "<S-Tab>".__raw = ''
              cmp.mapping(function(fallback)
                local cmp = require('cmp')
                local luasnip = require('luasnip')
                if cmp.visible() then cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                else fallback() end
              end, { "i", "s" })
            '';
            "<CR>".__raw = "require('cmp').mapping.confirm({ select = false })";
            "<C-Space>".__raw = "require('cmp').mapping.complete()";
            "<C-e>".__raw = "require('cmp').mapping.abort()";
          };
        };
      };

      # ── UI ────────────────────────────────────────────────────
      plugins.web-devicons.enable = true;

      plugins.lualine = {
        enable = true;
        settings = {
          options = {
            theme = "onedark";
            component_separators = "";
            section_separators = {
              left = "";
              right = "";
            };
            globalstatus = true;
          };
          sections = {
            lualine_a = [
              {
                __unkeyed-1.__raw = ''
                  function()
                    local modes = {
                      n = "NORMAL", i = "INSERT", v = "VISUAL",
                      V = "V·LINE", ["\22"] = "V·BLOCK",
                      c = "COMMAND", R = "REPLACE", s = "SELECT",
                    }
                    return modes[vim.fn.mode()] or vim.fn.mode()
                  end
                '';
                padding = {
                  left = 2;
                  right = 2;
                };
              }
            ];
            lualine_b = [
              {
                __unkeyed-1 = "branch";
                icon = "";
              }
            ];
            lualine_c = [
              {
                __unkeyed-1 = "filename";
                path = 1;
                symbols = {
                  modified = " ●";
                  readonly = " ";
                };
              }
              {
                __unkeyed-1 = "diagnostics";
                sources = ["nvim_lsp"];
              }
            ];
            lualine_x = [
              {__unkeyed-1 = "diff";}
              {
                __unkeyed-1 = "filetype";
                colored = true;
                icon_only = false;
              }
            ];
            lualine_y = ["progress"];
            lualine_z = [
              {
                __unkeyed-1 = "location";
                padding = {
                  left = 1;
                  right = 2;
                };
              }
            ];
          };
        };
      };

      plugins.bufferline = {
        enable = true;
        settings.options = {
          mode = "buffers";
          separator_style = "slant";
          show_buffer_close_icons = true;
          show_close_icon = false;
          diagnostics = "nvim_lsp";
          always_show_bufferline = true;
          offsets = [
            {
              filetype = "NvimTree";
              text = "  Explorer";
              highlight = "Directory";
              separator = true;
            }
          ];
        };
      };

      plugins.nvim-tree = {
        enable = true;
        settings = {
          view = {
            width = 35;
            side = "left";
          };
          renderer = {
            indent_markers.enable = true;
            icons.show = {
              file = true;
              folder = true;
              git = true;
            };
            highlight_git = true;
          };
          filters.dotfiles = false;
          git.enable = true;
          diagnostics = {
            enable = true;
            show_on_dirs = true;
          };
          actions.open_file.quit_on_open = false;
          update_focused_file = {
            enable = true;
            update_root = false;
          };
        };
      };

      plugins.snacks = {
        enable = true;
        settings = {
          picker = {
            matcher = {
              fuzzy = false;
              smartcase = true;
            };
            sources = {
              files = {
                hidden = true;
                follow = true;
              };
              grep.hidden = true;
              grep_word.hidden = true;
            };
            win.input.keys = {
              "<C-j>" = ["list_down" ["i" "n"]];
              "<C-k>" = ["list_up" ["i" "n"]];
              "<esc>" = ["close" ["i" "n"]];
            };
          };
          notifier = {
            enabled = true;
            timeout = 3000;
            style = "compact";
            top_down = false;
          };
          terminal.enabled = true;
          words.enabled = true;
          indent = {
            enabled = true;
            indent.char = "│";
            scope = {
              enabled = true;
              hl = "Function";
            };
          };
          scroll.enabled = true;
          lazygit.enabled = true;
          bufdelete.enabled = true;
          rename.enabled = true;
          input.enabled = true;
          gitbrowse.enabled = true;
          dashboard.enabled = false;
          statuscolumn.enabled = false;
          bigfile.enabled = false;
        };
      };

      plugins.comment.enable = true;
      plugins.nvim-surround.enable = true;

      plugins.nvim-autopairs = {
        enable = true;
        settings.disable_filetype = ["snacks_input"];
      };

      plugins.spectre.enable = true;

      plugins.which-key = {
        enable = true;
        settings = {
          win.border = "rounded";
          icons = {
            breadcrumb = "»";
            separator = "→";
            group = "+";
            provider = "mini";
          };
          spec = [
            {
              __unkeyed-1 = "<leader>f";
              group = "Find";
            }
            {
              __unkeyed-1 = "<leader>g";
              group = "Git";
            }
            {
              __unkeyed-1 = "<leader>t";
              group = "Terminal";
            }
            {
              __unkeyed-1 = "<leader>h";
              group = "Replace";
            }
            {
              __unkeyed-1 = "<leader>n";
              group = "Notifications";
            }
            {
              __unkeyed-1 = "<leader>r";
              group = "Rename";
            }
            {
              __unkeyed-1 = "<leader>c";
              group = "Cargo / Rust";
            }
            {
              __unkeyed-1 = "<leader>d";
              group = "Debug";
            }
            {
              __unkeyed-1 = "g";
              group = "Go to / Actions";
            }
            {
              __unkeyed-1 = "]";
              group = "Next";
            }
            {
              __unkeyed-1 = "[";
              group = "Prev";
            }
          ];
        };
      };

      # mini.icons : requis par which-key (icons.provider = "mini") ; on ne
      # sort pas les autres modules de mini.nvim car on n'en a pas besoin ici.
      # onedark-nvim : thème, chargé/configuré dynamiquement plus bas.
      extraPlugins = with pkgs.vimPlugins; [mini-nvim onedark-nvim];
      extraConfigLuaPre = ''
        require('mini.icons').setup()
      '';

      # ── THÈME (Zed One Dark) : partie volontairement laissée en Lua ─────
      # Le thème doit pouvoir changer à chaud (fichier ~/.config/theme/mode
      # et ~/.config/theme/transparency modifiés par un outil externe, sans
      # rebuild Nix) : ce comportement dynamique n'a pas d'équivalent
      # déclaratif raisonnable, c'est l'usage prévu de `extraConfigLua`.
      extraConfigLua = ''
        local _theme_file = vim.fn.expand("~/.config/theme/mode")
        local _transparency_file = vim.fn.expand("~/.config/theme/transparency")

        local function read_theme_mode()
          local f = io.open(_theme_file, "r")
          if f then
            local m = f:read("*l"); f:close()
            return (m == "light") and "light" or "dark"
          end
          return "dark"
        end

        local function read_transparency()
          local f = io.open(_transparency_file, "r")
          if f then
            local m = f:read("*l"); f:close()
            return m == "on"
          end
          return false
        end

        local _theme_mode = read_theme_mode()
        local _theme_transparent = read_transparency()

        local function apply_theme(mode, transparent)
          vim.o.background = mode
          local opts = {
            transparent          = transparent,
            term_colors          = true,
            ending_tildes        = false,
            cmp_itemkind_colored = true,
            highlights = {
              NormalFloat  = { bg = "$bg1" },
              FloatBorder  = { fg = "$bg3", bg = "$bg1" },
              WinSeparator = { fg = "$bg3" },
            },
          }
          if mode == "dark" then
            opts.style  = "darker"
            opts.colors = {
              bg0     = "#1a1a1f",
              bg1     = "#1f1f26",
              bg2     = "#252530",
              bg3     = "#2d2d3a",
              bg_d    = "#151519",
              bg_blue = "#3b4261",
              fg      = "#cdd6f4",
              purple  = "#c678dd",
              green   = "#98c379",
              orange  = "#d19a66",
              blue    = "#61afef",
              yellow  = "#e5c07b",
              cyan    = "#56b6c2",
              red     = "#e06c75",
              grey    = "#5c6370",
            }
          else
            opts.style = "light"
          end
          require("onedark").setup(opts)
          require("onedark").load()
        end

        apply_theme(_theme_mode, _theme_transparent)

        vim.api.nvim_create_user_command("SetTheme", function(cmdopts)
          apply_theme(cmdopts.args, _theme_transparent)
        end, { nargs = 1 })

        local _theme_watcher = vim.uv.new_fs_event()
        if _theme_watcher then
          _theme_watcher:start(_theme_file, {}, vim.schedule_wrap(function(err)
            if not err then
              _theme_mode = read_theme_mode()
              apply_theme(_theme_mode, _theme_transparent)
            end
          end))
        end

        local _transparency_watcher = vim.uv.new_fs_event()
        if _transparency_watcher then
          _transparency_watcher:start(_transparency_file, {}, vim.schedule_wrap(function(err)
            if not err then
              _theme_transparent = read_transparency()
              apply_theme(_theme_mode, _theme_transparent)
            end
          end))
        end
      '';
    };
  };
}
