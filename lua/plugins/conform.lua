local function parse_diff_hunks(lines)
  local ranges = {}
  for _, line in ipairs(lines) do
    local start_line, count = line:match("^@@ %-%d+,?%d* %+(%d+),(%d+) @@")
    if not start_line then
      start_line = line:match("^@@ %-%d+,?%d* %+(%d+) @@")
      count = "1"
    end
    if start_line and count then
      local s = tonumber(start_line)
      local c = tonumber(count)
      if s and c and c > 0 then
        ranges[#ranges + 1] = { start_line = s, end_line = s + c - 1 }
      end
    end
  end
  return ranges
end

local function format_uncommitted_hunks(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify("Buffer has no file path", vim.log.levels.WARN)
    return
  end

  local dir = vim.fs.dirname(file)
  local git_root = vim.fs.root(dir, { ".git" })
  if not git_root then
    vim.notify("Not inside a git repository", vim.log.levels.WARN)
    return
  end

  local rel = file
  local prefix = git_root .. "/"
  if vim.startswith(file, prefix) then
    rel = file:sub(#prefix + 1)
  end
  local cmd = { "git", "-C", git_root, "diff", "--no-color", "-U0", "HEAD", "--", rel }
  local diff_lines = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to read git diff for current file", vim.log.levels.ERROR)
    return
  end

  local ranges = parse_diff_hunks(diff_lines)
  if #ranges == 0 then
    vim.notify("No uncommitted changed lines to format", vim.log.levels.INFO)
    return
  end

  local conform = require("conform")
  table.sort(ranges, function(a, b)
    return a.start_line > b.start_line
  end)

  for _, range in ipairs(ranges) do
    local end_text = vim.api.nvim_buf_get_lines(bufnr, range.end_line - 1, range.end_line, false)[1] or ""
    conform.format({
      bufnr = bufnr,
      lsp_format = "fallback",
      range = {
        start = { range.start_line, 0 },
        ["end"] = { range.end_line, #end_text },
      },
    })
  end
end

return {
  "stevearc/conform.nvim",
  keys = {
    {
      "<leader>cf",
      function()
        format_uncommitted_hunks(0)
      end,
      desc = "Format Uncommitted Diff Hunks",
    },
  },
  opts = function()
    local opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        -- java uses LSP (jdtls) formatter via fallback
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
    }
    return opts
  end,
}
