vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ─── THÈME MODE ──────────────────────────────────────────────
local _theme_mode = (function()
  local f = io.open(vim.fn.expand("~/.config/theme/mode"), "r")
  if f then
    local m = f:read("*l"); f:close()
    return (m == "light") and "light" or "dark"
  end
  return "dark"
end)()

local function apply_theme(mode)
  vim.o.background = mode
  local opts = {
    transparent          = false,
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

-- ─── THEME FILE WATCHER ──────────────────────────────────────
local _theme_file = vim.fn.expand("~/.config/theme/mode")
local _theme_watcher = vim.uv.new_fs_event()
if _theme_watcher then
  _theme_watcher:start(_theme_file, {}, vim.schedule_wrap(function(err)
    if not err then
      local f = io.open(_theme_file, "r")
      if f then
        local m = f:read("*l"); f:close()
        apply_theme((m == "light") and "light" or "dark")
      end
    end
  end))
end

-- ─── OPTIONS GÉNÉRALES ───────────────────────────────────────
local opt = vim.opt

-- Apparence
opt.number         = true
opt.relativenumber = false
opt.cursorline     = true
opt.signcolumn     = "yes"          -- toujours afficher la colonne des signes
opt.colorcolumn    = ""
opt.termguicolors  = true
opt.background     = _theme_mode
opt.showmode       = false          -- le statusline s'en charge
opt.laststatus     = 3              -- statusline global (comme Zed)
opt.cmdheight      = 0              -- masquer la cmdline au repos (style Zed)
opt.pumheight      = 10
opt.winblend       = 0
opt.pumblend       = 0

-- Éditeur
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true
opt.smartindent    = true
opt.wrap           = false
opt.linebreak      = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.splitbelow     = true
opt.splitright     = true
opt.virtualedit    = "block"        -- sélection rectangulaire libre

-- Recherche
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = true
opt.incsearch      = true

-- Performances / UX
opt.updatetime     = 200
opt.timeoutlen     = 300
opt.undofile       = true
opt.backup         = false
opt.swapfile       = false
opt.clipboard      = "unnamedplus"  -- presse-papier système
opt.confirm        = true

-- Complétion
opt.completeopt    = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- ─── LAZY.NVIM BOOTSTRAP ─────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ─── HELPER : localiser un plugin injecté par Nix dans le rtp ───
-- Nix wraps neovim avec --cmd "set rtp^=..." AVANT que init.lua tourne.
-- On scanne donc le rtp ici pour trouver le path Nix du plugin.
local function nix_rtp_path(pattern)
  for _, p in ipairs(vim.api.nvim_list_runtime_paths()) do
    if p:find(pattern, 1, false) then return p end
  end
  return nil
end

-- Open the logs directory in a buffer --

local function open_nvim_state_dir()
  local state_dir = vim.fn.expand("$HOME/.local/state/nvim")
  vim.cmd("edit " .. vim.fn.fnameescape(state_dir))
end

-- Path de nvim-treesitter dans le store Nix (nil si non-NixOS)
local ts_nix_dir = nix_rtp_path("nvim%-treesitter")

-- ─── PLUGINS ─────────────────────────────────────────────────
require("lazy").setup({

  -- ── THÈME (Zed One Dark / light) ─────────────────────────
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      apply_theme(_theme_mode)
      vim.api.nvim_create_user_command("SetTheme", function(opts)
        apply_theme(opts.args)
      end, { nargs = 1 })
    end,
  },

  -- ── ICÔNES ───────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── STATUSLINE ─────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local function zed_mode()
        local modes = {
          n  = "NORMAL", i  = "INSERT", v  = "VISUAL",
          V  = "V·LINE", ["\22"] = "V·BLOCK",
          c  = "COMMAND", R = "REPLACE", s  = "SELECT",
        }
        return modes[vim.fn.mode()] or vim.fn.mode()
      end
      require("lualine").setup({
        options = {
          theme            = "onedark",
          component_separators = "",
          section_separators  = { left = "", right = "" },
          globalstatus     = true,
        },
        sections = {
          lualine_a = { { zed_mode, padding = { left = 2, right = 2 } } },
          lualine_b = { { "branch", icon = "" } },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " " } },
            { "diagnostics", sources = { "nvim_lsp" } },
          },
          lualine_x = {
            { "diff" },
            { "filetype", colored = true, icon_only = false },
          },
          lualine_y = { "progress" },
          lualine_z = { { "location", padding = { left = 1, right = 2 } } },
        },
      })
    end,
  },

  -- ── BUFFERLINE ───────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          mode              = "buffers",
          separator_style   = "slant",
          show_buffer_close_icons = true,
          show_close_icon   = false,
          diagnostics       = "nvim_lsp",
          always_show_bufferline = true,
          offsets = {
            { filetype = "NvimTree", text = "  Explorer", highlight = "Directory", separator = true },
          },
        },
      })
    end,
  },

  -- ── EXPLORATEUR DE FICHIERS ─────────
  {
    "nvim-tree/nvim-tree.lua",
    cmd  = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", desc = "Toggle file tree" },
    },
    config = function()
      require("nvim-tree").setup({
        view  = { width = 35, side = "left" },
        renderer = {
          indent_markers = { enable = true },
          icons = { show = { file = true, folder = true, git = true } },
          highlight_git = true,
        },
        filters     = { dotfiles = false },
        git         = { enable = true },
        diagnostics = { enable = true, show_on_dirs = true },
        actions     = { open_file = { quit_on_open = false } },
        update_focused_file = { enable = true, update_root = false },
      })
    end,
  },

  -- ── SNACKS (picker, terminal, notifier, indent, words, scroll …) ──
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy     = false,
    keys = {
      -- ── Picker (Telescope replacement) ──────────────────────────
      { "<leader><space>", function() Snacks.picker.files() end,                 desc = "Find files" },
      { "<leader>/",       function() Snacks.picker.grep() end,                  desc = "Project search" },
      { "<leader>fb",      function() Snacks.picker.buffers() end,               desc = "Buffers" },
      { "<leader>fh",      function() Snacks.picker.help() end,                  desc = "Help" },
      { "<leader>fs",      function() Snacks.picker.lsp_symbols() end,           desc = "Document symbols" },
      { "<leader>fS",      function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },
      { "<leader>fd",      function() Snacks.picker.diagnostics() end,           desc = "Diagnostics" },
      { "<leader>fr",      function() Snacks.picker.recent() end,                desc = "Recent files" },
      { "<leader>fc",      function() Snacks.picker.commands() end,              desc = "Commands" },
      { "<leader>fw",      function() Snacks.picker.grep_word() end,             desc = "Search word" },
      { "<leader>fg",      function() Snacks.picker.git_files() end,             desc = "Git files" },
      { "<leader>fl",      function() Snacks.picker.lines() end,                 desc = "Buffer lines" },
      { "<leader>fk",      function() Snacks.picker.keymaps() end,               desc = "Keymaps" },
      { "<leader>fm",      function() Snacks.picker.marks() end,                 desc = "Marks" },
      { "<leader>fu",      function() Snacks.picker.undo() end,                  desc = "Undo history" },
      { "<leader>fp",      function() Snacks.picker.resume() end,                desc = "Resume picker" },
      -- ── Terminal (Toggleterm replacement) ────────────────────────
      { "<C-&>",      function() Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } }) end, desc = "Toggle terminal" },
      { "<leader>tt", function() Snacks.terminal.toggle(nil, { win = { position = "float" } }) end,               desc = "Float terminal" },
      { "<leader>tv", function() Snacks.terminal.toggle(nil, { win = { position = "right", width = 0.4 } }) end,  desc = "Vertical terminal" },
      -- ── Git ──────────────────────────────────────────────────────
      { "<leader>gg", function() Snacks.lazygit() end,                            desc = "LazyGit" },
      { "<leader>gB", function() Snacks.gitbrowse() end,                         desc = "Git browse" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end,                  desc = "Lazygit file log" },
      { "<leader>gl", function() Snacks.picker.git_log() end,                    desc = "Git log" },
      { "<leader>gL", function() Snacks.picker.git_log_file() end,               desc = "Git log (file)" },
      { "<leader>gS", function() Snacks.picker.git_status() end,                 desc = "Git status" },
      { "<leader>gc", function() Snacks.picker.git_branches() end,               desc = "Git branches" },
      -- ── Notifier ─────────────────────────────────────────────────
      { "<leader>nh", function() Snacks.notifier.show_history() end,             desc = "Notification history" },
      { "<leader>nd", function() Snacks.notifier.hide() end,                     desc = "Dismiss notifications" },
      { "<leader>nl", function() open_nvim_state_dir() end,                      desc = "Show logs directory" },
      -- ── Words ────────────────────────────────────────────────────
      { "]]", function() Snacks.words.jump(1,  true) end,                        desc = "Next reference" },
      { "[[", function() Snacks.words.jump(-1, true) end,                        desc = "Prev reference" },
      -- ── Misc ─────────────────────────────────────────────────────
      { "<leader>bd", function() Snacks.bufdelete() end,                         desc = "Delete buffer" },
      { "<leader>rF", function() Snacks.rename.rename_file() end,                desc = "Rename file" },
    },
    opts = {
      -- ── Picker ────────────────────────────────────────────────────
      -- fuzzy = false → exact substring match (fixes incomplete search results)
      -- hidden = true → includes dotfiles, same as rg --hidden
      picker = {
        matcher = { fuzzy = false, smartcase = true },
        sources = {
          files     = { hidden = true, follow = true },
          grep      = { hidden = true },
          grep_word = { hidden = true },
        },
        win = {
          input = {
            keys = {
              ["<C-j>"] = { "list_down", mode = { "i", "n" } },
              ["<C-k>"] = { "list_up",   mode = { "i", "n" } },
              ["<esc>"] = { "close",     mode = { "i", "n" } },
            },
          },
        },
      },
      -- ── Notifier (nvim-notify + noice replacement) ────────────────
      notifier = { enabled = true, timeout = 3000, style = "compact", top_down = false },
      -- ── Terminal (Toggleterm replacement) ─────────────────────────
      terminal  = { enabled = true },
      -- ── Words (vim-illuminate replacement) ────────────────────────
      words     = { enabled = true },
      -- ── Indent (indent-blankline replacement) ─────────────────────
      indent = {
        enabled = true,
        indent  = { char = "│" },
        scope   = { enabled = true, hl = "Function" },
      },
      -- ── Smooth scroll (neoscroll replacement) ─────────────────────
      scroll    = { enabled = true },
      -- ── Extras ────────────────────────────────────────────────────
      lazygit   = { enabled = true },
      bufdelete = { enabled = true },
      rename    = { enabled = true },
      input     = { enabled = true },
      gitbrowse = { enabled = true },
      -- Disabled snacks features
      dashboard    = { enabled = false },
      statuscolumn = { enabled = false },
      bigfile      = { enabled = false },
    },
  },

  -- ── TREESITTER ─────────────────────────────────────────────
  -- Sur NixOS  : ts_nix_dir pointe vers le store Nix → lazy utilise ce
  --              path directement, pas de clone git, parsers pré-compilés.
  -- Hors NixOS : ts_nix_dir = nil → lazy clone depuis GitHub normalement.
  {
    "nvim-treesitter/nvim-treesitter",
    -- Si Nix a mis le plugin dans le rtp, on le pointe directement.
    -- lazy n'essaiera pas de le télécharger ou compiler quoi que ce soit.
    dir    = ts_nix_dir,   -- nil sur non-NixOS → comportement lazy normal
    build  = ts_nix_dir and nil or ":TSUpdate",
    event  = "BufReadPost",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- NixOS : parsers pré-compilés dans le store, rien à installer
        -- Autre : lazy gère l'installation via ensure_installed
        auto_install     = ts_nix_dir == nil,
        ensure_installed = ts_nix_dir and {} or {
          "lua", "vim", "vimdoc", "javascript", "typescript", "tsx",
          "python", "rust", "go", "c", "cpp", "json", "yaml", "toml",
          "html", "css", "markdown", "markdown_inline", "bash", "regex",
        },
        sync_install   = false,
        ignore_install = {},
        highlight = {
          enable                            = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable  = true,
          keymaps = {
            init_selection   = "<C-space>",
            node_incremental = "<C-space>",
            node_decremental = "<BS>",
          },
        },
      })
    end,
  },

  -- ── LSP ──────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
    },
    config = function()
      require("neodev").setup()
      -- ── Raccourcis LSP calqués sur Zed vim-mode ─────────────
      -- on_attach est défini AVANT mason-lspconfig.setup() car les
      -- handlers y sont déclarés inline (API mason-lspconfig v2).
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        -- Navigation (identique Zed vim-mode)
        map("n", "gd",  vim.lsp.buf.definition,       "Go to definition")
        map("n", "gD",  vim.lsp.buf.declaration,       "Go to declaration")
        map("n", "gy",  vim.lsp.buf.type_definition,   "Go to type definition")
        map("n", "gi",  vim.lsp.buf.implementation,    "Go to implementation")
        map("n", "gr",  vim.lsp.buf.references,        "Find references")
        map("n", "gR",  vim.lsp.buf.references,        "Find references (alt)")

        -- Informations (Zed : gh → hover)
        map("n", "gh",  vim.lsp.buf.hover,             "Hover docs")
        map("n", "gH",  vim.lsp.buf.signature_help,    "Signature help")

        -- Actions (Zed : <Space>a / ga)
        map("n", "ga",        vim.lsp.buf.code_action, "Code action")
        map("v", "ga",        vim.lsp.buf.code_action, "Code action (visual)")
        map("n", "<leader>a", vim.lsp.buf.code_action, "Code action")

        -- Renommer (Zed : <Space>r)
        map("n", "<leader>r", vim.lsp.buf.rename, "Rename symbol")

        -- Formater (Zed : <Space>f)
        map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format file")
        map("v", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format selection")

        -- Diagnostics (Zed : ]d / [d  et  <Space>e)
        map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        map("n", "]e", function()
          vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
        end, "Next error")
        map("n", "[e", function()
          vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
        end, "Prev error")
        map("n", "<leader>E", vim.diagnostic.open_float, "Show diagnostics")
        map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics to loclist")

        -- Hover / Symbols
        map("n", "<leader>k", vim.lsp.buf.hover, "Hover docs")
        map("n", "<leader>s", function() Snacks.picker.lsp_symbols() end,           "Document symbols")
        map("n", "<leader>S", function() Snacks.picker.lsp_workspace_symbols() end, "Workspace symbols")
      end

      -- Config diagnostics visuels 
      vim.diagnostic.config({
        virtual_text     = { prefix = "●", spacing = 4 },
        signs            = true,
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
        float            = { border = "rounded", source = "always" },
      })

      local signs = { Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- ── mason-lspconfig v2 : handlers déclarés dans setup() ──
      -- setup_handlers() a été supprimé en v2. Les handlers vont
      -- maintenant dans la clé `handlers` de setup().
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason").setup({ ui = { border = "rounded" } })
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "ts_ls", "pyright", "rust_analyzer",
          "gopls", "cssls", "html", "jsonls", "nil_ls"
        },
        automatic_installation = true,
        -- Handler par défaut : appliqué à tous les serveurs installés
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              on_attach    = on_attach,
              capabilities = capabilities,
            })
          end,
        },
      })
    end,
  },

  -- ── COMPLÉTION (style Zed inline) ────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered({ border = "rounded" }),
          documentation = cmp.config.window.bordered({ border = "rounded" }),
        },
        formatting = {
          format = lspkind.cmp_format({
            mode       = "symbol_text",
            maxwidth   = 50,
            ellipsis_char = "…",
          }),
        },
        -- Navigation façon Zed : Tab/S-Tab pour naviguer, Enter pour valider
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<C-d>"]     = cmp.mapping.scroll_docs(4),
          ["<C-u>"]     = cmp.mapping.scroll_docs(-4),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500, keyword_length = 3 },
          { name = "path",     priority = 250 },
        }),
      })
    end,
  },

  -- ── GIT (gutter comme Zed) ───────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        current_line_blame = true,
        current_line_blame_opts = { delay = 500, virt_text_pos = "eol" },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          -- Zed : ]g / [g pour naviguer dans les hunks
          map("n", "]g", gs.next_hunk,        "Next git hunk")
          map("n", "[g", gs.prev_hunk,        "Prev git hunk")
          map("n", "<leader>gp", gs.preview_hunk,    "Preview hunk")
          map("n", "<leader>gs", gs.stage_hunk,      "Stage hunk")
          map("n", "<leader>gr", gs.reset_hunk,      "Reset hunk")
          map("n", "<leader>gb", gs.blame_line,       "Blame line")
          map("n", "<leader>gd", gs.diffthis,         "Diff this")
        end,
      })
    end,
  },

  -- ── PAIRES AUTO (brackets comme Zed) ─────────────────────
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts              = true,
        ts_config             = { lua = { "string" }, javascript = { "template_string" } },
        fast_wrap             = { map = "<M-e>", chars = { "{", "[", "(", '"', "'" } },
        disable_filetype      = { "snacks_input" },
      })
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ── SURROUND (Zed : cs / ys) ─────────────────────────────
  {
    "kylechui/nvim-surround",
    event   = "VeryLazy",
    config  = true,
  },

  -- ── COMMENTAIRES (Zed : cmd-/ → gcc/gc) ──────────────────
  {
    "numToStr/Comment.nvim",
    event  = "BufReadPost",
    config = true,
  },

  -- ── RECHERCHE / SUBSTITUTION AMÉLIORÉE ───────────────────
  {
    "nvim-pack/nvim-spectre",
    keys = {
      -- <Space>h  → rechercher et remplacer (Zed : cmd-shift-h)
      { "<leader>h",  "<cmd>Spectre<cr>",                                             desc = "Search & replace" },
      { "<leader>hw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search word" },
    },
    config = true,
  },

  -- ── WHICH-KEY (aide contextuelle aux raccourcis) ─────────
  {
    "folke/which-key.nvim",
    event  = "VeryLazy",
    -- mini.icons est fourni par nixpkgs (mini-nvim), pas besoin de le
    -- déclarer comme dépendance lazy : il est déjà dans le runtimepath.
    init = function()
      -- Initialiser mini.icons avant which-key pour éviter le warning
      require("mini.icons").setup()
    end,
    config = function()
      require("which-key").setup({
        win   = { border = "rounded" },
        icons = {
          breadcrumb = "»",
          separator  = "→",
          group      = "+",
          -- Utiliser mini.icons comme fournisseur d'icônes (élimine le warning)
          provider   = "mini",
        },
      })
      require("which-key").add({
        { "<leader>f",  group = "Find / Format" },
        { "<leader>g",  group = "Git" },
        { "<leader>t",  group = "Terminal" },
        { "<leader>h",  group = "Replace" },
        { "<leader>n",  group = "Notifications" },
        { "<leader>r",  group = "Rename" },
        { "g",          group = "Go to / Actions" },
        { "]",          group = "Next" },
        { "[",          group = "Prev" },
      })
    end,
  },

}, {
  -- Options lazy.nvim
  ui = { border = "rounded" },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  -- Empêcher lazy de gérer nvim-treesitter (géré par Nix/nixpkgs)
  performance = {
    rtp = {
      disabled_plugins = {},
    },
  },
})

-- ─── RACCOURCIS GLOBAUX (hors LSP) ───────────────────────────

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Fenêtres  (Navigation Zed : cmd+hjkl)
map("n", "<C-h>",  "<C-w>h",  "Window left")
map("n", "<C-j>",  "<C-w>j",  "Window down")
map("n", "<C-k>",  "<C-w>k",  "Window up")
map("n", "<C-l>",  "<C-w>l",  "Window right")

-- Redimensionner
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          "Resize up")
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          "Resize down")
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", "Resize left")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", "Resize right")

-- Buffers  (Zed : ctrl+tab)
map("n", "<S-l>",      "<cmd>bnext<cr>",     "Next buffer")
map("n", "<S-h>",      "<cmd>bprevious<cr>", "Prev buffer")
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<cr>", "Close other buffers")

-- Fichier alternatif (Zed : ctrl+6)
map("n", "<C-6>",  "<C-^>", "Alternate file")

-- Annuler le surlignage de recherche (Zed : Esc hors insert)
map("n", "<esc>",  "<cmd>nohl<cr><esc>", "Clear search highlight")

-- Indentation en Visual sans quitter le mode
map("v", "<",  "<gv", "Indent left")
map("v", ">",  ">gv", "Indent right")

-- Déplacer les lignes (Zed : alt+up/down)
map("n", "<A-j>", "<cmd>m .+1<cr>==",       "Move line down")
map("n", "<A-k>", "<cmd>m .-2<cr>==",       "Move line up")
map("v", "<A-j>", ":m '>+1<cr>gv=gv",       "Move selection down")
map("v", "<A-k>", ":m '<-2<cr>gv=gv",       "Move selection up")

-- Coller sans remplacer le registre (Zed : paste normal)
map("v", "p",  '"_dP', "Paste without yanking")

-- Tout sélectionner (Zed : cmd+a)
map("n", "<leader>A",  "ggVG", "Select all")

-- Sauvegarder (Zed : cmd+s)
map("n", "<C-s>",  "<cmd>w<cr>",  "Save file")
map("i", "<C-s>",  "<esc><cmd>w<cr>", "Save file")

-- Fermer la fenêtre
map("n", "<leader>wq", "<cmd>q<cr>",  "Quit window")
map("n", "<leader>ww", "<cmd>w<cr>",  "Save")

-- Ouvrir Lazy
map("n", "<leader>L",  "<cmd>Lazy<cr>",  "Open Lazy")

-- Ouvrir Mason
map("n", "<leader>M",  "<cmd>Mason<cr>", "Open Mason")

-- ─── AUTOCOMMANDES ───────────────────────────────────────────

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Surligner la sélection lors du yank (comme Zed)
autocmd("TextYankPost", {
  group    = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Revenir à la dernière position du curseur dans le buffer
autocmd("BufReadPost", {
  group    = augroup("LastPosition", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Fermer certains filetypes avec q
autocmd("FileType", {
  group   = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "lspinfo", "man", "notify", "snacks_notif", "qf", "spectre_panel", "startuptime" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Navigation dans les terminaux snacks (et tout autre :terminal)
autocmd("TermOpen", {
  group    = augroup("TermMappings", { clear = true }),
  callback = function()
    local t = function(lhs, rhs) vim.keymap.set("t", lhs, rhs, { buffer = 0, silent = true }) end
    t("<esc>",  [[<C-\><C-n>]])
    t("<C-h>", [[<Cmd>wincmd h<CR>]])
    t("<C-j>", [[<Cmd>wincmd j<CR>]])
    t("<C-k>", [[<Cmd>wincmd k<CR>]])
    t("<C-l>", [[<Cmd>wincmd l<CR>]])
  end,
})
