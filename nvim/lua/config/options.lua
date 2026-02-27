vim.opt.clipboard = "unnamedplus" -- Use the system clipboard for all yanks

local function is_wsl()
  local version_file = io.open("/proc/version", "r")
  if version_file then
    local content = version_file:read("*a")
    version_file:close()
    return content:lower():find("microsoft") ~= nil
  end
  return false
end

if is_wsl() then
  -- WSL: use win32yank to bridge to Windows clipboard
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
elseif os.getenv("WAYLAND_DISPLAY") then
  -- Native Linux on Wayland: use wl-clipboard
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy --primary",
    },
    paste = {
      ["+"] = "wl-paste --no-newline",
      ["*"] = "wl-paste --no-newline --primary",
    },
    cache_enabled = 0,
  }
else
  -- Native Linux on X11: use xclip (or xsel if you prefer)
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = "xclip -selection clipboard -o",
      ["*"] = "xclip -selection primary -o",
    },
    cache_enabled = 0,
  }
end
