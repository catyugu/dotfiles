return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          mason = false,
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
          },
          init_options = {
            -- 这里设置默认语言标准
            fallbackFlags = { "-std=c++20" }, -- 或 "-std=c++17", "-std=c17"
          },
        },
        cssls = {}, -- Enables the CSS Language Server
        tsserver = {
          settings = {
            javascript = { format = { enable = true } },
            typescript = { format = { enable = true } },
          },
        },
        tailwindcss = {},
        html = {
          filetypes = { "html", "jsx", "tsx", "js", "ts" }, -- add more if needed
          init_options = {
            provideFormatter = true,
          },
        },
      },
    },
  },
}
