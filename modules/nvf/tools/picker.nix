{ ... }:
{
  flake.nvfModules.picker = { pkgs, lib, ... }: {
  config.vim = {
    # Telescope is fully retired in favour of Snacks' picker: one picker for
    # files, grep, buffers, symbols and git, and it drops plenary + fzf-native
    # from the closure. nvf keeps this false so its own default cannot pull
    # telescope back in.
    telescope.enable = false;

    keymaps = [
      # ─── Picker ───────────────────────────────────────────────────────────
      # Same <leader>f* / <leader>g* bindings as the telescope setup these
      # replace, so the muscle memory carries over.
      {
        key = "<leader>ff";
        mode = "n";
        action = "function() Snacks.picker.files({ hidden = true }) end";
        lua = true;
        desc = "Find files";
      }
      {
        key = "<leader>fg";
        mode = "n";
        action = "function() Snacks.picker.grep() end";
        lua = true;
        desc = "Live grep";
      }
      {
        key = "<leader>fb";
        mode = "n";
        action = "function() Snacks.picker.buffers() end";
        lua = true;
        desc = "Find buffers";
      }
      {
        key = "<leader>fh";
        mode = "n";
        action = "function() Snacks.picker.help() end";
        lua = true;
        desc = "Help tags";
      }
      {
        key = "<leader>fr";
        mode = "n";
        action = "function() Snacks.picker.recent() end";
        lua = true;
        desc = "Recent files";
      }
      {
        key = "<leader>fd";
        mode = "n";
        action = "function() Snacks.picker.diagnostics() end";
        lua = true;
        desc = "Diagnostics";
      }
      {
        key = "<leader>fw";
        mode = "n";
        action = "function() Snacks.picker.grep_word() end";
        lua = true;
        desc = "Find word under cursor";
      }
      {
        key = "<leader>fk";
        mode = "n";
        action = "function() Snacks.picker.keymaps() end";
        lua = true;
        desc = "Keymaps";
      }
      {
        key = "<leader>fc";
        mode = "n";
        action = "function() Snacks.picker.commands() end";
        lua = true;
        desc = "Commands";
      }
      {
        key = "<leader>fm";
        mode = "n";
        action = "function() Snacks.picker.marks() end";
        lua = true;
        desc = "Marks";
      }
      {
        key = "<leader>fs";
        mode = "n";
        action = "function() Snacks.picker.lsp_symbols() end";
        lua = true;
        desc = "Document symbols";
      }
      {
        key = "<leader>fS";
        mode = "n";
        action = "function() Snacks.picker.lsp_workspace_symbols() end";
        lua = true;
        desc = "Workspace symbols";
      }
      {
        key = "<leader>gc";
        mode = "n";
        action = "function() Snacks.picker.git_log() end";
        lua = true;
        desc = "Git commits";
      }
      {
        key = "<leader>gt";
        mode = "n";
        action = "function() Snacks.picker.git_status() end";
        lua = true;
        desc = "Git status";
      }
      {
        key = "<leader><leader>";
        mode = "n";
        action = "function() Snacks.picker.resume() end";
        lua = true;
        desc = "Resume last search";
      }
    ];
  };
};
}
