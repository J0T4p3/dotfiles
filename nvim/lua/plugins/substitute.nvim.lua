return {
  "gbprod/substitute.nvim",
  opts = {},
  keys = {
    {
      "ga",
      function()
        require("substitute").operator()
      end,
      desc = "Substitute operator",
    },
    {
      "gl",
      function()
        require("substitute").line()
      end,
      desc = "Substitute line",
    },
    {
      "gR",
      function()
        require("substitute").eol()
      end,
      desc = "Substitute to end of line",
    },
    {
      "ga",
      function()
        require("substitute").visual()
      end,
      mode = "x",
      desc = "Substitute visual",
    },
  },
}
