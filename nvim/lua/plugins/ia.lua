-- =============================================================================
-- ai.lua — Unified Agentic AI Config (CopilotChat + Avante)
-- Drop into: ~/.config/nvim/lua/plugins/ai.lua  (lazy.nvim)
--
-- ── FULL LAZYVIM <leader>c AUDIT ─────────────────────────────────────────────
-- Every letter LazyVim occupies under <leader>c (DO NOT USE these):
--
--   ca  → Code Action              (nvim-lspconfig)
--   cA  → Source Action            (nvim-lspconfig)
--   cd  → Line Diagnostics         (nvim-lspconfig / keymaps.lua)
--   cf  → Format                   (keymaps.lua)
--   cF  → Format Injected Langs    (conform.nvim)
--   cl  → Lsp Info                 (nvim-lspconfig)
--   cm  → Mason                    (mason.nvim)
--   co  → Organize Imports         (nvim-lspconfig / typescript)
--   cR  → Rename File              (nvim-lspconfig / Snacks)
--   cr  → Rename                   (nvim-lspconfig — <leader>cr = rename symbol)
--   cs  → Symbols (Trouble)        (trouble.nvim)
--   cS  → LSP refs/defs (Trouble)  (trouble.nvim)
--
-- ── LETTERS STILL FREE under <leader>c ───────────────────────────────────────
--   cb, cc, ce, ch, ci, cj, ck, cn, cp, cq, ct, cu, cv, cw, cx, cy, cz
--   (and uppercase variants not listed above)
--
-- ── FULL LAZYVIM <leader>a AUDIT ─────────────────────────────────────────────
-- LazyVim does NOT define any <leader>a bindings in its core config.
-- <leader>a is fully free — Avante owns it safely.
--
-- ── INSERT-MODE <C-letter> AUDIT ─────────────────────────────────────────────
--   NEVER remap these (native Neovim insert-mode):
--     <C-a>  insert previously inserted text
--     <C-e>  insert char from line below cursor
--     <C-h>  backspace
--     <C-j>  newline (same as <Enter>)
--     <C-k>  insert digraph (also used by LSP signature help in LazyVim)
--     <C-n>  next completion
--     <C-p>  prev completion
--     <C-r>  insert register
--     <C-t>  indent line
--     <C-u>  delete to start of line
--     <C-v>  insert literal char / visual block
--     <C-w>  delete word before cursor
--     <C-x>  enter completion sub-mode
--     <C-y>  copy char from line above cursor
--     <C-[>  THIS IS <Esc> — never remap
--     <C-]>  trigger digraph (risky on some terminals)
--   SAFE to use: <M-*> (Alt/Meta) keys have no native insert-mode bindings
-- =============================================================================

return {

  -- ─────────────────────────────────────────────────────────────────────────
  -- 1. COPILOT — base inline completion engine
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      vim.g.copilot_no_tab_map = true

      -- All Alt/Meta bindings — zero native insert-mode clashes
      vim.keymap.set("i", "<M-y>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Copilot: Accept suggestion",
      })
      vim.keymap.set("i", "<M-n>", "<Plug>(copilot-next)", { desc = "Copilot: Next suggestion" })
      vim.keymap.set("i", "<M-p>", "<Plug>(copilot-previous)", { desc = "Copilot: Prev suggestion" })
      vim.keymap.set("i", "<M-d>", "<Plug>(copilot-dismiss)", { desc = "Copilot: Dismiss" })
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- 2. COPILOTCHAT — conversational agent with buffer/diagnostic awareness
  --
  --  Prefix used: <leader>p ("ai Prompt")
  --  Rationale: <leader>c is almost fully claimed by LazyVim's LSP/code group.
  --  <leader>p has no LazyVim defaults and reads naturally as "Prompt/ai".
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    event = "VeryLazy",
    dependencies = {
      "github/copilot.vim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },

    opts = {
      model = "gpt-4o",
      agent = "copilot",
      context = "buffer", -- full file context by default

      window = {
        layout = "vertical",
        width = 0.35,
        border = "rounded",
        title = " Copilot Chat ",
      },

      auto_follow_cursor = true,
      auto_insert_mode = false,
      show_help = false,

      prompts = {
        Fix = {
          prompt = "/COPILOT_GENERATE Fix all bugs in the selected code. "
            .. "Return only the corrected code with no explanation.",
        },
        Refactor = {
          prompt = "/COPILOT_GENERATE Refactor the selected code for readability, "
            .. "performance, and idiomatic style. Return only the refactored code.",
        },
        AddTypes = {
          prompt = "/COPILOT_GENERATE Add proper type annotations / type hints to "
            .. "the selected code. Return only the typed code.",
        },
        WriteTests = {
          prompt = "/COPILOT_GENERATE Write comprehensive unit tests for the selected "
            .. "code. Use the project's existing test framework if detectable.",
        },
        Docs = {
          prompt = "/COPILOT_GENERATE Add clear docstrings / JSDoc comments to the "
            .. "selected code. Return only the documented code.",
        },
        Review = {
          prompt = "Review the selected code. List issues as numbered points: "
            .. "bugs, edge cases, performance problems, and style violations.",
        },
        Explain = {
          prompt = "Explain the selected code in plain English. "
            .. "Be concise. Focus on the 'why', not just the 'what'.",
        },
      },
    },

    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      chat.setup(opts)

      local function ask(prompt, ctx)
        chat.ask(prompt, { selection = ctx or select.visual })
      end

      -- ── Normal mode  <leader>p_ ──────────────────────────────────────────
      --  pp  toggle chat panel
      --  px  reset / clear chat
      --  pb  review whole buffer
      --  pd  fix all LSP diagnostics in buffer
      --  pi  free-prompt inline ask (also visual)
      --  ph  telescope: prompt history picker

      vim.keymap.set("n", "<leader>pp", chat.toggle, { desc = "Chat: Toggle panel" })
      vim.keymap.set("n", "<leader>px", chat.reset, { desc = "Chat: Reset / clear" })

      vim.keymap.set("n", "<leader>pb", function()
        ask("Review this file and suggest concrete improvements.", select.buffer)
      end, { desc = "Chat: Review buffer" })

      vim.keymap.set("n", "<leader>pd", function()
        ask("Fix every LSP diagnostic in this buffer.", select.diagnostics)
      end, { desc = "Chat: Fix diagnostics" })

      vim.keymap.set({ "n", "v" }, "<leader>pi", function()
        local input = vim.fn.input("Ask Copilot: ")
        if input ~= "" then
          ask(input)
        end
      end, { desc = "Chat: Inline ask (free prompt)" })

      vim.keymap.set("n", "<leader>ph", function()
        require("CopilotChat.integrations.telescope").pick(require("CopilotChat.actions").prompt_actions())
      end, { desc = "Chat: Prompt history (Telescope)" })

      -- ── Visual mode  <leader>p_ ──────────────────────────────────────────
      --  pf  fix selection
      --  pr  refactor selection
      --  pt  write tests
      --  py  add types         (y = tYpe — avoids pt clash with "tests" ambiguity)
      --  pv  document (docstrings)  (v = docu-V... admittedly a stretch, but free)
      --  pe  explain selection

      vim.keymap.set("v", "<leader>pf", function()
        ask("/fix")
      end, { desc = "Chat: Fix selection" })
      vim.keymap.set("v", "<leader>pr", function()
        ask("/refactor")
      end, { desc = "Chat: Refactor selection" })
      vim.keymap.set("v", "<leader>pt", function()
        ask("/writetests")
      end, { desc = "Chat: Write tests" })
      vim.keymap.set("v", "<leader>py", function()
        ask("/addtypes")
      end, { desc = "Chat: Add types" })
      vim.keymap.set("v", "<leader>pv", function()
        ask("/docs")
      end, { desc = "Chat: Document selection" })
      vim.keymap.set("v", "<leader>pe", function()
        ask("/explain")
      end, { desc = "Chat: Explain selection" })
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- 3. AVANTE — Cursor-style inline diff editing
  --
  --  Prefix used: <leader>a ("AI / Avante")
  --  LazyVim has zero <leader>a bindings — this prefix is fully free.
  --
  --  Diff-panel bare bindings (only active inside Avante's diff buffer):
  --    `co`  accept ours    — safe, mirrors vim's own :diffget ours convention
  --    `ct`  accept theirs  — safe, `ct` alone never fires (needs a {char} target)
  --    `cm`  accept both    — free, no default normal-mode binding
  --
  -- ── RATE LIMIT NOTES ────────────────────────────────────────────────────
  --  The main sources of rate limiting with Copilot are:
  --
  --  1. auto_suggestions = true  ← THE biggest culprit. This fires a Copilot
  --     request on every cursor movement / keystroke. The Avante source itself
  --     warns this is "dangerous" with Copilot as the provider. KEEP IT FALSE.
  --
  --  2. suggestion.debounce / throttle  — controls how long Avante waits before
  --     firing a suggestion request after you stop typing. Default is 600ms.
  --     Raised here to 1500ms to give you time to finish a thought.
  --
  --  3. copilot.vim inline completions  — a separate request stream from Avante.
  --     Both run simultaneously when you type. To avoid doubling the request
  --     rate, copilot.vim's suggestion panel is disabled while Avante is open
  --     (see the autocmd in the config function below).
  --
  --  4. max_tokens  — lowered from unlimited to 4096. Huge token counts keep
  --     the connection open longer and exhaust rate budgets faster.
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    dependencies = {
      "github/copilot.vim",
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },

    opts = {
      provider = "copilot",

      -- ── Provider settings (new schema: all providers live under `providers`) ──
      -- Migration guide: https://github.com/yetone/avante.nvim/wiki/Provider-configuration-migration-guide
      -- Old top-level `copilot = { ... }` is deprecated — use `providers.copilot` instead.
      -- `extra_request_body` is the new home for temperature, max_tokens, etc.
      providers = {
        copilot = {
          model = "gpt-4o",
          -- Keep max_tokens reasonable — large values hold the connection open
          -- longer and burn through Copilot's rate budget much faster.
          extra_request_body = {
            max_tokens = 4096,
            temperature = 0, -- deterministic output = less token waste on retries
          },
        },
      },

      -- ── Suggestion throttling ────────────────────────────────────────────
      -- debounce: ms to wait after you STOP typing before firing a request.
      -- throttle: minimum ms between any two consecutive requests.
      -- Both default to 600ms upstream; raised here to reduce request frequency.
      suggestion = {
        debounce = 1500,
        throttle = 1500,
      },

      -- ── Behaviour ────────────────────────────────────────────────────────
      behaviour = {
        -- !! CRITICAL: never enable auto_suggestions with Copilot provider.
        -- It fires a request on every cursor event and will hit rate limits
        -- within seconds. Use explicit <leader>aa / <leader>ae instead.
        auto_suggestions = false,

        auto_apply_diff_after_generation = false, -- review diffs before applying
        auto_set_keymaps = true,
        auto_set_highlight_group = true,
        support_paste_from_clipboard = true,
        minimize_diff = true, -- shrinks context sent per request
        enable_token_counting = true, -- shows token usage so you can monitor
      },

      ui = {
        border = "rounded",
        width = 0.65,
        height = 0.8,
        show_loading = true,
      },

      diff = {
        autojump = true,
        list_opener = "copen",
      },

      mappings = {
        ask = "<leader>aa", -- open Avante ask panel
        edit = "<leader>ae", -- inline edit selection
        refresh = "<leader>aR", -- regenerate last suggestion

        diff = {
          ours = "co", -- accept our version  (safe in diff buf, vim convention)
          theirs = "ct", -- accept their version (safe: `ct` needs a {char} to fire)
          both = "cm", -- accept both / merge  (cm = free in normal mode)
          next = "]h", -- next hunk
          prev = "[h", -- prev hunk
        },

        submit = {
          normal = "<CR>",
          insert = "<C-s>", -- safe: no native insert-mode binding for <C-s>
        },
      },

      hints = { enabled = true },
    },

    config = function(_, opts)
      require("avante").setup(opts)

      -- ── Pause copilot.vim inline completions while Avante panel is open ──
      -- Both plugins talk to Copilot simultaneously when active. Pausing
      -- copilot.vim's ghost-text stream while you're in an Avante session
      -- halves the request rate and removes the most common cause of limits.
      local copilot_enabled = true

      vim.api.nvim_create_autocmd("User", {
        pattern = "AvanteOpen", -- fired by avante when its sidebar opens
        callback = function()
          if copilot_enabled then
            vim.cmd("Copilot disable")
            copilot_enabled = false
          end
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "AvanteClose", -- fired by avante when its sidebar closes
        callback = function()
          if not copilot_enabled then
            vim.cmd("Copilot enable")
            copilot_enabled = true
          end
        end,
      })
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- 4. WHICH-KEY group labels
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "󰚩 Avante (inline edit)" },
        { "<leader>p", group = " Copilot Chat" },
      },
    },
  },
}
