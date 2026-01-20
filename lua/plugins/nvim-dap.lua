return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      local vscode = require("dap.ext.vscode")

      -- 1. FIX DEPRECATION: Override the JSON decoder to handle comments in launch.json
      -- This is the modern replacement for the old manual loading logic
      vscode.json_decode = function(str)
        return vim.json.decode(vim.fn.json_encode(vim.json.decode(str)))
      end

      -- 2. Define your fixed/manual configurations
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 8000,
        },
      }

      -- 3. MODERN LOADING: This helper automatically finds .vscode/launch.json 
      -- and maps the 'java' type correctly without a global merge conflict.
      if vim.fn.filereadable(".vscode/launch.json") == 1 then
        vscode.load_launchjs(nil, { java = { "java" } })
      end
    end,
  },
}
