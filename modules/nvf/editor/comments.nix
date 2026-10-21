{ ... }:
{
  michi.nvfModules.comments = { lib, ... }: {
    config.vim = {
      # NOTE: the standalone config has no comment plugin — builtin gc/gb
      # commenting is used as-is. Only todo-comments is ported here.

      notes.todo-comments = {
        enable = true;
        setupOpts = {
          signs = true;
          sign_priority = 8;
          keywords = {
            FIX = {
              icon = lib.mkLuaInline ''"\u{F188}"'';
              color = "error";
              alt = [
                "FIXME"
                "BUG"
                "FIXIT"
                "ISSUE"
              ];
            };
            TODO = {
              icon = lib.mkLuaInline ''"\u{F00C}"'';
              color = "info";
            };
            HACK = {
              icon = lib.mkLuaInline ''"\u{F490}"'';
              color = "warning";
            };
            WARN = {
              icon = lib.mkLuaInline ''"\u{F071}"'';
              color = "warning";
              alt = [
                "WARNING"
                "XXX"
              ];
            };
            PERF = {
              icon = "";
              alt = [
                "OPTIM"
                "PERFORMANCE"
                "OPTIMIZE"
              ];
            };
            NOTE = {
              icon = lib.mkLuaInline ''"\u{F0368}"'';
              color = "hint";
              alt = [ "INFO" ];
            };
            TEST = {
              icon = "⏲ ";
              color = "test";
              alt = [
                "TESTING"
                "PASSED"
                "FAILED"
              ];
            };
          };
          merge_keywords = true;
          highlight = {
            multiline = true;
            multiline_pattern = "^.";
            multiline_context = 10;
            before = "";
            keyword = "wide";
            after = "fg";
            pattern = ''.*<(KEYWORDS)\s*:'';
            comments_only = true;
            max_line_len = 400;
            exclude = [ ];
          };
          search = {
            command = "rg";
            args = [
              "--color=never"
              "--no-heading"
              "--with-filename"
              "--line-number"
              "--column"
            ];
            pattern = ''\b(KEYWORDS):'';
          };
        };
      };

      keymaps = [
        {
          key = "]t";
          mode = "n";
          action = "function() require('todo-comments').jump_next() end";
          lua = true;
          desc = "Next TODO";
        }
        {
          key = "[t";
          mode = "n";
          action = "function() require('todo-comments').jump_prev() end";
          lua = true;
          desc = "Previous TODO";
        }
        {
          key = "<leader>ft";
          mode = "n";
          action = "<cmd>TodoTrouble<cr>";
          desc = "Find TODOs (Trouble)";
        }
        {
          key = "<leader>fT";
          mode = "n";
          action = "<cmd>TodoQuickFix keywords=TODO,FIX,FIXME<cr>";
          desc = "Find TODO/FIX/FIXME (quickfix)";
        }
      ];
    };
  };
}
