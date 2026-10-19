{ ... }:
{
  michi.nvfModules.noice = { ... }: {
  config.vim = {
    ui.noice = {
      enable = true;
      setupOpts = {
        lsp = {
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
          };
          hover = {
            enabled = true;
          };
          # blink.cmp owns the automatic signature window (completion.nix);
          # keeping noice's would render a second signature popup.
          signature = {
            enabled = false;
          };
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = true;
          lsp_doc_border = true;
        };
        routes = [
          {
            filter = {
              event = "msg_show";
              kind = "";
              find = "written";
            };
            opts = {
              skip = true;
            };
          }
        ];
      };
    };

    notify.nvim-notify = {
      enable = true;
      setupOpts = {
        background_colour = "#1e1e2e";
      };
    };

    keymaps = [
      {
        key = "<S-Enter>";
        mode = "c";
        action = "function() require('noice').redirect(vim.fn.getcmdline()) end";
        lua = true;
        desc = "Redirect cmdline";
      }
      {
        key = "<leader>snl";
        mode = "n";
        action = "function() require('noice').cmd('last') end";
        lua = true;
        desc = "Noice last message";
      }
      {
        key = "<leader>snh";
        mode = "n";
        action = "function() require('noice').cmd('history') end";
        lua = true;
        desc = "Noice history";
      }
      {
        key = "<leader>sna";
        mode = "n";
        action = "function() require('noice').cmd('all') end";
        lua = true;
        desc = "Noice all";
      }
      {
        key = "<leader>snd";
        mode = "n";
        action = "function() require('noice').cmd('dismiss') end";
        lua = true;
        desc = "Dismiss all";
      }
    ];
  };
}
;
}
