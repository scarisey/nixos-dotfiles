return {
  {
    "hrsh7th/nvim-cmp",
    requires = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-vsnip" },
      { "hrsh7th/vim-vsnip" },
    },
  },
  {
    "scalameta/nvim-metals",
    as = "metals",
    ft = { "scala", "sbt", "java" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "mfussenegger/nvim-dap",
        config = function()
          local dap = require("dap")
          dap.configurations.scala = {
            {
              type = "metals",
              request = "launch",
              name = "runortest",
              metals = {
                runttype = "runortestfile",
              },
            },
            {
              type = "scala",
              request = "launch",
              name = "test target",
              metals = {
                runttype = "testtarget",
              },
            },
          }
        end,
      },
      {
        "folke/which-key.nvim",
        opts = {
          defaults = {
            ["<leader>mm"] = { name = "metals actions" },
          },
        },
      },
    },
    keys = { { "<leader>mm", "<cmd>:lua require'telescope'.extensions.metals.commands()<cr>" } },
    config = function()
      local metals = require("metals")
      local metals_config = metals.bare_config()
      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
      }
      metals_config.init_options.statusBarProvider = "on"
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- Begin DAP - Debug settings if you're using nvim-dap
      local dap = require("dap")

      dap.configurations.scala = {
        {
          type = "scala",
          request = "launch",
          name = "RunOrTest",
          metals = {
            runType = "runOrTestFile",
            --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
          },
        },
        {
          type = "scala",
          request = "launch",
          name = "Test Target",
          metals = {
            runType = "testTarget",
          },
        },
      }
      metals_config.on_attach = function(client, bufnr)
        metals.setup_dap()
      end
      -- End DAP
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt", "java" },
        callback = function()
          metals.initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },
}
