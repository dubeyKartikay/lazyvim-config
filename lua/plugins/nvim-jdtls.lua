return {
  "mfussenegger/nvim-jdtls",
  dependencies = { "folke/which-key.nvim" },
  opts = function(_, opts)
    local formatter_path = vim.fn.stdpath("config") .. "/jdtls-formatter.xml"
    local cmd = { vim.fn.exepath("jdtls") }
    if LazyVim.has("mason.nvim") then
      local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
      table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
    end

    opts.cmd = cmd

    opts.root_dir = function(path)
      return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
    end

    opts.project_name = function(root_dir)
      return root_dir and vim.fs.basename(root_dir)
    end

    opts.jdtls_config_dir = function(project_name)
      return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
    end

    opts.jdtls_workspace_dir = function(project_name)
      return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
    end

    opts.full_cmd = function(o)
      local fname = vim.api.nvim_buf_get_name(0)
      local root_dir = o.root_dir(fname)
      local project_name = o.project_name(root_dir)
      local c = vim.deepcopy(o.cmd)
      if project_name then
        vim.list_extend(c, {
          "-configuration",
          o.jdtls_config_dir(project_name),
          "-data",
          o.jdtls_workspace_dir(project_name),
        })
      end
      return c
    end

    opts.dap = { hotcodereplace = "auto", config_overrides = {} }
    opts.dap_main = {}
    opts.test = true

    -- Ensure settings table exists
    opts.settings = opts.settings or {}
    opts.settings.java = opts.settings.java or {}

    -- Use the workspace formatter profile to keep Java indentation stable.
    opts.settings.java.format = {
      enabled = true,
      settings = {
        url = vim.uri_from_fname(formatter_path),
        profile = "IntelliJStyle",
      },
    }

    opts.settings.java.saveActions = {
      organizeImports = false,
    }

    opts.settings.java.sources = {
      organizeImports = {
        starThreshold = 5,
        staticStarThreshold = 3,
      },
    }

    opts.settings.java.completion = {
      importOrder = {
        "#",
        "java",
        "javax",
        "org",
        "com",
        "",
      },
    }

    opts.settings.java.inlayHints = {
      parameterNames = {
        enabled = "all",
      },
    }

    opts.settings.java.configuration = {
      runtimes = {
        {
          name = "JavaSE-17",
          path = "/Library/Java/JavaVirtualMachines/openjdk-17.jdk",
        },
        {
          name = "JavaSE-1_8",
          path = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/",
        },
      },
    }

    local orig_on_attach = opts.on_attach
    opts.on_attach = function(args)
      vim.bo[args.buf].expandtab = true
      vim.bo[args.buf].tabstop = 4
      vim.bo[args.buf].softtabstop = 4
      vim.bo[args.buf].shiftwidth = 4
      if orig_on_attach then
        orig_on_attach(args)
      end
    end

    return opts
  end,
}
