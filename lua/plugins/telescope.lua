return {
  "ibhagwan/fzf-lua",
  opts = {
    winopts = {
      fullscreen = true,
      preview = {
        hidden = false
      }
    },
    files = {
      formatter = "path.filename_first",
      file_icons = true,
      git_icons = true,
    },
  },
}
