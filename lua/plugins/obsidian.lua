return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ft = "markdown",
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    note_id_func = function (title)
      local safe_title = title:gsub(" ", "-"):gsub("%W", "")
      return safe_title
    end,
    workspaces = {
      {
        name = "notes",
        path = "~/my_notes",
      },
    },
  },
}
