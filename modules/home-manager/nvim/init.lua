-- ============================================================
--  Neovim · Configuration inspirée de Zed Editor
--  Structure : Options → Lazy bootstrap → Plugins → Keymaps
-- ============================================================

-- ─── LEADER ──────────────────────────────────────────────────
-- Zed utilise <Space> comme leader pour toutes ses actions
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ─── OPTIONS GÉNÉRALES ───────────────────────────────────────
local opt = vim.opt

-- Apparence
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"          -- toujours afficher la colonne des signes
opt.colorcolumn    = ""
opt.termguicolors  = true
opt.background     = "dark"
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

-- ─── PLUGINS ─────────────────────────────────────────────────
require("lazy").setup({

  -- ── THÈME (Zed One Dark) ─────────────────────────────────
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({
        style            = "darker",   -- "dark" | "darker" | "cool" | "deep"
        transparent      = false,
        term_colors      = true,
        ending_tildes    = false,
        cmp_itemkind_colored = true,
        -- Personnalisation pour coller à Zed
        colors = {
          bg0      = "#1a1a1f",
          bg1      = "#1f1f26",
          bg2      = "#252530",
          bg3      = "#2d2d3a",
          bg_d     = "#151519",
          bg_blue  = "#3b4261",
          fg       = "#cdd6f4",
          purple   = "#c678dd",
          green    = "#98c379",
          orange   = "#d19a66",
          blue     = "#61afef",
          yellow   = "#e5c07b",
          cyan     = "#56b6c2",
          red      = "#e06c75",
          grey     = "#5c6370",
        },
        highlights = {
          -- UI transparente style Zed
          NormalFloat  = { bg = "$bg1" },
          FloatBorder  = { fg = "$bg3", bg = "$bg1" },
          WinSeparator = { fg = "$bg3" },
        },
      })
      require("onedark").load()
    end,
  },

  -- ── ICÔNES ───────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── STATUSLINE (style Zed : minimaliste) ─────────────────
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

  -- ── BUFFERLINE (onglets comme Zed) ───────────────────────
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

  -- ── EXPLORATEUR DE FICHIERS (panneau gauche Zed) ─────────
  {
    "nvim-tree/nvim-tree.lua",
    cmd  = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
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
      })
    end,
  },

  -- ── TELESCOPE (command palette / file picker Zed) ────────
  {
    "nvim-telescope/telescope.nvim",
    tag  = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      -- <Space><Space>  → fichiers  (Zed : cmd-p)
      { "<leader><space>", "<cmd>Telescope find_files<cr>",              desc = "Find files" },
      -- <Space>/        → recherche dans le projet  (Zed : cmd-shift-f)
      { "<leader>/",       "<cmd>Telescope live_grep<cr>",               desc = "Project search" },
      { "<leader>fb",      "<cmd>Telescope buffers<cr>",                 desc = "Buffers" },
      { "<leader>fh",      "<cmd>Telescope help_tags<cr>",               desc = "Help" },
      { "<leader>fs",      "<cmd>Telescope lsp_document_symbols<cr>",    desc = "Document symbols" },
      { "<leader>fS",      "<cmd>Telescope lsp_workspace_symbols<cr>",   desc = "Workspace symbols" },
      { "<leader>fd",      "<cmd>Telescope diagnostics<cr>",             desc = "Diagnostics" },
      { "<leader>fr",      "<cmd>Telescope oldfiles<cr>",                desc = "Recent files" },
      { "<leader>fc",      "<cmd>Telescope commands<cr>",                desc = "Commands" },
      -- Recherche mot sous curseur (Zed : cmd-shift-f sélection)
      { "<leader>fw",      "<cmd>Telescope grep_string<cr>",             desc = "Search word" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix   = "  ",
          selection_caret = " ",
          layout_strategy = "horizontal",
          layout_config   = { prompt_position = "top", width = 0.85, height = 0.80 },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "node_modules", ".git/" },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<esc>"] = "close",
            },
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- ── TREESITTER ────────────────────────────────────────────
  -- NB : sur NixOS, nvim-treesitter est fourni par nixpkgs (parsers
  -- pré-compilés). Il est déjà dans le runtimepath au démarrage.
  -- On l'exclut de lazy pour éviter le conflit d'environnement LuaJIT.
  -- Sa configuration se trouve APRÈS require("lazy").setup(), ci-dessous.

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
      require("mason").setup({ ui = { border = "rounded" } })
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "ts_ls", "pyright", "rust_analyzer",
          "gopls", "cssls", "html", "jsonls",
        },
        automatic_installation = true,
      })

      -- Raccourcis LSP calqués sur Zed vim-mode
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

        -- Actions  (Zed : <Space>a / ga)
        map("n", "ga",           vim.lsp.buf.code_action,   "Code action")
        map("v", "ga",           vim.lsp.buf.code_action,   "Code action (visual)")
        map("n", "<leader>a",    vim.lsp.buf.code_action,   "Code action")

        -- Renommer  (Zed : <Space>r)
        map("n", "<leader>r",    vim.lsp.buf.rename,        "Rename symbol")

        -- Formater  (Zed : <Space>f)
        map("n", "<leader>f",    function()
          vim.lsp.buf.format({ async = true })
        end, "Format file")
        map("v", "<leader>f",    function()
          vim.lsp.buf.format({ async = true })
        end, "Format selection")

        -- Diagnostics  (Zed : ]d / [d  et  <Space>e)
        map("n", "]d",  vim.diagnostic.goto_next,      "Next diagnostic")
        map("n", "[d",  vim.diagnostic.goto_prev,      "Prev diagnostic")
        map("n", "]e",  function()
          vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
        end, "Next error")
        map("n", "[e",  function()
          vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
        end, "Prev error")
        map("n", "<leader>E",   vim.diagnostic.open_float,  "Show diagnostics")
        map("n", "<leader>q",   vim.diagnostic.setloclist,  "Diagnostics to loclist")

        -- Hover (raccourci Zed <Space>k)
        map("n", "<leader>k",   vim.lsp.buf.hover,          "Hover docs (alt)")

        -- Symbols  (Zed : <Space>s)
        map("n", "<leader>s",  "<cmd>Telescope lsp_document_symbols<cr>",   "Document symbols")
        map("n", "<leader>S",  "<cmd>Telescope lsp_workspace_symbols<cr>",  "Workspace symbols")
      end

      -- Config diagnostics visuels (style Zed)
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

      -- Appliquer on_attach à tous les serveurs
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            on_attach    = on_attach,
            capabilities = capabilities,
          })
        end,
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

  -- ── INDENTATION GUIDES (Zed en a nativement) ─────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = "BufReadPost",
    config = function()
      require("ibl").setup({
        indent  = { char = "│", tab_char = "│" },
        scope   = { enabled = true, highlight = "Function" },
        exclude = { filetypes = { "help", "NvimTree", "lazy" } },
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
        disable_filetype      = { "TelescopePrompt" },
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

  -- ── TERMINAL (Zed a un terminal intégré) ─────────────────
  {
    "akinsho/toggleterm.nvim",
    keys = {
      -- Zed : ctrl+` pour le terminal
      { "<C-`>",       "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle terminal" },
      { "<leader>tt",  "<cmd>ToggleTerm direction=float<cr>",      desc = "Float terminal" },
      { "<leader>tv",  "<cmd>ToggleTerm direction=vertical<cr>",   desc = "Vertical terminal" },
    },
    config = function()
      require("toggleterm").setup({
        size            = function(term)
          if term.direction == "horizontal" then return 15
          elseif term.direction == "vertical" then return vim.o.columns * 0.4
          end
        end,
        float_opts      = { border = "curved", width = 100, height = 30 },
        shade_terminals = true,
      })
      -- Quitter le mode terminal avec <Esc>
      function _G.set_terminal_keymaps()
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { buffer = 0 })
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { buffer = 0 })
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { buffer = 0 })
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { buffer = 0 })
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { buffer = 0 })
      end
      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
  },

  -- ── WHICH-KEY (aide contextuelle aux raccourcis) ─────────
  {
    "folke/which-key.nvim",
    event  = "VeryLazy",
    config = function()
      require("which-key").setup({
        window = { border = "rounded" },
        icons  = { breadcrumb = "»", separator = "→", group = "+" },
      })
      require("which-key").add({
        { "<leader>f",  group = "Find / Format" },
        { "<leader>g",  group = "Git" },
        { "<leader>t",  group = "Terminal" },
        { "<leader>h",  group = "Replace" },
        { "g",          group = "Go to / Actions" },
        { "]",          group = "Next" },
        { "[",          group = "Prev" },
      })
    end,
  },

  -- ── NOTIFICATIONS STYLE ZED ──────────────────────────────
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        render   = "minimal",
        stages   = "fade",
        timeout  = 3000,
        top_down = false,
      })
      vim.notify = require("notify")
    end,
  },

  -- ── NOICE (UI commandes façon Zed) ───────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"]               = true,
            ["cmp.entry.get_documentation"]                 = true,
          },
          hover      = { enabled = true },
          signature  = { enabled = true },
        },
        presets = {
          bottom_search         = true,
          command_palette       = true,
          long_message_to_split = true,
          inc_rename            = false,
        },
      })
    end,
  },

  -- ── SMOOTH SCROLL (UX Zed) ───────────────────────────────
  {
    "karb94/neoscroll.nvim",
    event  = "VeryLazy",
    config = function()
      require("neoscroll").setup({
        mappings       = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
        easing_function = "quadratic",
      })
    end,
  },

  -- ── HIGHLIGHT MOT SOUS CURSEUR (Zed le fait nativement) ──
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay     = 100,
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

-- ─── TREESITTER (configuré hors lazy — géré par nixpkgs) ─────
-- nvim-treesitter est dans le runtimepath via programs.neovim.plugins
-- Les parsers sont pré-compilés dans le store Nix, pas besoin de :TSUpdate
vim.defer_fn(function()
  local ok, configs = pcall(require, "nvim-treesitter.configs")
  if not ok then
    vim.notify("nvim-treesitter non trouvé dans le runtimepath.\n"
      .. "Vérifier programs.neovim.plugins dans neovim.nix", vim.log.levels.WARN)
    return
  end
  configs.setup({
    -- Nix fournit les parsers : ne rien installer à la volée
    auto_install   = false,
    ensure_installed = {},     -- vide : tout est déjà dans le store Nix
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
end, 0)

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
map("n", "<leader>bd", "<cmd>bdelete<cr>",   "Delete buffer")
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
  pattern = { "help", "lspinfo", "man", "notify", "qf", "spectre_panel", "startuptime" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- ─── FIN ─────────────────────────────────────────────────────
-- Place ce fichier dans ~/.config/nvim/init.lua
-- Premier lancement : nvim → lazy.nvim installe tout automatiquement

