{ lib, ... }: {
  config.vim = {
    augroups = [
      {
        name = "YankHighlight";
        clear = true;
      }
      {
        name = "ResizeSplits";
        clear = true;
      }
      {
        name = "LastPosition";
        clear = true;
      }
      {
        name = "CloseWithQ";
        clear = true;
      }
      {
        name = "AutoCreateDir";
        clear = true;
      }
      {
        name = "TrimWhitespace";
        clear = true;
      }
      {
        name = "Checktime";
        clear = true;
      }
      {
        name = "WrapSpell";
        clear = true;
      }
      {
        name = "JsonConceal";
        clear = true;
      }
      {
        name = "NoAutoComment";
        clear = true;
      }
      {
        name = "TermSettings";
        clear = true;
      }
      {
        name = "BigFile";
        clear = true;
      }
    ];

    autocmds = [
      # Highlight on yank
      {
        event = [ "TextYankPost" ];
        group = "YankHighlight";
        callback = lib.mkLuaInline ''
          function()
            vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
          end
        '';
        desc = "Highlight on yank";
      }

      # Resize splits when window is resized
      {
        event = [ "VimResized" ];
        group = "ResizeSplits";
        callback = lib.mkLuaInline ''
          function()
            local current_tab = vim.fn.tabpagenr()
            vim.cmd("tabdo wincmd =")
            vim.cmd("tabnext " .. current_tab)
          end
        '';
        desc = "Resize splits on window resize";
      }

      # Go to last cursor position when opening a file
      {
        event = [ "BufReadPost" ];
        group = "LastPosition";
        callback = lib.mkLuaInline ''
          function(event)
            local exclude = { "gitcommit" }
            local buf = event.buf
            if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
              return
            end
            vim.b[buf].lazyvim_last_loc = true
            local mark = vim.api.nvim_buf_get_mark(buf, '"')
            local lcount = vim.api.nvim_buf_line_count(buf)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
        desc = "Go to last cursor position";
      }

      # Close certain filetypes with q
      {
        event = [ "FileType" ];
        group = "CloseWithQ";
        pattern = [
          "PlenaryTestPopup"
          "checkhealth"
          "dbout"
          "gitsigns.blame"
          "help"
          "lspinfo"
          "neotest-output"
          "neotest-output-panel"
          "neotest-summary"
          "notify"
          "qf"
          "spectre_panel"
          "startuptime"
          "tsplayground"
        ];
        callback = lib.mkLuaInline ''
          function(event)
            vim.bo[event.buf].buflisted = false
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
          end
        '';
        desc = "Close window with q for specific filetypes";
      }

      # Auto create directories when saving a file
      {
        event = [ "BufWritePre" ];
        group = "AutoCreateDir";
        callback = lib.mkLuaInline ''
          function(event)
            if event.match:match("^%w%w+:[\\/][\\/]") then
              return
            end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end
        '';
        desc = "Auto create directory when saving a file";
      }

      # Remove trailing whitespace on save
      {
        event = [ "BufWritePre" ];
        group = "TrimWhitespace";
        pattern = [ "*" ];
        callback = lib.mkLuaInline ''
          function()
            local save_cursor = vim.fn.getpos(".")
            pcall(function()
              vim.cmd([[%s/\s\+$//e]])
            end)
            vim.fn.setpos(".", save_cursor)
          end
        '';
        desc = "Remove trailing whitespace on save";
      }

      # Check if file changed when window is focused
      {
        event = [
          "FocusGained"
          "TermClose"
          "TermLeave"
        ];
        group = "Checktime";
        callback = lib.mkLuaInline ''
          function()
            if vim.o.buftype ~= "nofile" then
              vim.cmd("checktime")
            end
          end
        '';
        desc = "Checktime on focus gained";
      }

      # Wrap and spell check in text filetypes
      {
        event = [ "FileType" ];
        group = "WrapSpell";
        pattern = [
          "text"
          "plaintex"
          "typst"
          "gitcommit"
          "markdown"
        ];
        callback = lib.mkLuaInline ''
          function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
          end
        '';
        desc = "Enable wrap and spell for text filetypes";
      }

      # Fix conceallevel for json files
      {
        event = [ "FileType" ];
        group = "JsonConceal";
        pattern = [
          "json"
          "jsonc"
          "json5"
        ];
        callback = lib.mkLuaInline ''
          function()
            vim.opt_local.conceallevel = 0
          end
        '';
        desc = "Disable conceal for json files";
      }

      # Don't auto-continue comments with o/O or Enter
      {
        event = [ "FileType" ];
        group = "NoAutoComment";
        pattern = [ "*" ];
        callback = lib.mkLuaInline ''
          function()
            vim.opt_local.formatoptions:remove({ "c", "r", "o" })
          end
        '';
        desc = "Stop comment continuation on o/O/Enter";
      }

      # Terminal buffers: no line numbers, drop straight into insert
      {
        event = [ "TermOpen" ];
        group = "TermSettings";
        callback = lib.mkLuaInline ''
          function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
            vim.cmd("startinsert")
          end
        '';
        desc = "Terminal buffer settings";
      }

      # Files over 1MiB drop treesitter folding and other heavy work.
      {
        event = [ "BufReadPre" ];
        group = "BigFile";
        callback = lib.mkLuaInline ''
          function(event)
            local ok, stat = pcall(vim.uv.fs_stat, event.match)
            if ok and stat and stat.size and stat.size > 1024 * 1024 then
              vim.b[event.buf].bigfile = true
              vim.opt_local.foldmethod = "manual"
              vim.opt_local.foldexpr = "0"
              vim.opt_local.spell = false
              vim.b[event.buf].illuminate_disabled = true
            end
          end
        '';
        desc = "Disable treesitter folding on large files";
      }
    ];

    # Neovim's runtime detects compose files as plain yaml, but the compose
    # language service targets `yaml.docker-compose`.
    luaConfigRC.filetype_overrides = ''
      vim.filetype.add({
        pattern = {
          ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
          ["compose.*%.ya?ml"] = "yaml.docker-compose",
        },
      })
    '';
  };
}
