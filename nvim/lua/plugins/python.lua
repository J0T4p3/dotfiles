return {
  {
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          pyright = {},
          ty = { enabled = false },
        },
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_change = true,
        },
      },
    },
    keys = {
      -- Keymap to open the venv selector
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
  },
}
