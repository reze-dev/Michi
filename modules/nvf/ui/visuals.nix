{ ... }:
{
  flake.nvfModules.visuals = { lib, ... }: {
  config.vim = {
    visuals = {
      nvim-web-devicons.enable = true;
      indent-blankline = {
        enable = true;
        setupOpts = {
          indent = {
            char = "│";
            tab_char = "│";
          };
          scope = {
            show_start = false;
            show_end = false;
            include = {
              node_type = {
                "*" = [
                  "argument_list"
                  "arguments"
                  "assignment_statement"
                  "block"
                  "chunk"
                  "class"
                  "do_block"
                  "element"
                  "except"
                  "for"
                  "function"
                  "if_statement"
                  "method"
                  "object"
                  "return_statement"
                  "table"
                  "try"
                  "while"
                ];
              };
            };
          };
          exclude = {
            filetypes = [
              "help"
              "dashboard"
              "snacks_dashboard"
              "lazy"
              "mason"
              "notify"
              "oil"
              "harpoon"
              "toggleterm"
            ];
          };
        };
      };
    };

    ui = {
      fastaction.enable = true;
      colorizer = {
        enable = true;
        setupOpts = {
          # nvf models colorizer's v2 `filetypes` table (ft -> overrides)
          # rather than the source's legacy list; "!" entries disable.
          filetypes = {
            "*" = { };
            "!lazy" = { };
            "!mason" = { };
            "!snacks_dashboard" = { };
            "!dashboard" = { };
          };
          user_default_options = {
            RGB = true;
            RRGGBB = true;
            names = false;
            RRGGBBAA = true;
            AARRGGBB = true;
            rgb_fn = true;
            hsl_fn = true;
            css = true;
            css_fn = true;
            mode = "background";
            tailwind = false;
            virtualtext = "■";
            always_update = false;
          };
        };
      };
      illuminate = {
        enable = true;
        setupOpts = {
          delay = 200;
          large_file_cutoff = 2000;
          large_file_overrides = {
            providers = [ "lsp" ];
          };
          filetypes_denylist = [
            "oil"
            "dashboard"
            "snacks_dashboard"
            "lazy"
            "mason"
            "snacks_picker_input"
            "snacks_picker_list"
            "TelescopePrompt"
            "dap-view"
            "dap-view-term"
          ];
        };
      };
    };

    utility.snacks-nvim = {
      enable = true;
      setupOpts = {
        # Picks up the explorer/input/scope/lazygit frontends that the
        # dashboard and the <leader>E / <leader>gg bindings below expect.
        explorer = {
          enabled = true;
        };
        input.enable = true;
        scope.enable = true;
        lazygit.enable = true;
        quickfile.enable = true;

        # Replaces telescope. picker.enabled is implied, set explicitly so the
        # dependency on it is visible rather than incidental.
        picker = {
          enabled = true;
        };

        # noice.nvim + nvim-notify already own vim.notify; leaving snacks'
        # notifier on gives two frontends fighting over it.
        notifier = {
          enabled = false;
        };

        # vim-illuminate owns the word under the cursor.
        words = {
          enabled = false;
        };

        dashboard = {
          enabled = true;
          preset = {
            keys = [
              {
                icon = lib.mkLuaInline ''"\u{F0F6} "'';
                key = "f";
                desc = "Find File";
                action = ":lua Snacks.picker.files()";
              }
              {
                icon = " ";
                key = "n";
                desc = "New File";
                action = ":ene | startinsert";
              }
              {
                icon = "󰱼 ";
                key = "g";
                desc = "Find Text";
                action = ":lua Snacks.picker.grep()";
              }
              {
                icon = " ";
                key = "r";
                desc = "Recent Files";
                action = ":lua Snacks.picker.recent()";
              }
              {
                icon = " ";
                key = "p";
                desc = "Projects";
                action = ":lua Snacks.picker.projects()";
              }
              {
                icon = " ";
                key = "c";
                desc = "Config";
                action = ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})";
              }
              {
                icon = lib.mkLuaInline ''"\u{F011} "'';
                key = "q";
                desc = "Quit";
                action = ":qa";
              }
            ];
            header = ''


                                                                                        
                          ████ ██████           █████      ██                     
                         ███████████             █████                             
                         █████████ ███████████████████ ███   ███████████   
                        █████████  ███    █████████████ █████ ██████████████   
                       █████████ ██████████ █████████ █████ █████ ████ █████   
                     ███████████ ███    ███ █████████ █████ █████ ████ █████  
                    ██████  █████████████████████ ████ █████ █████ ████ ██████ 






          '';
          };
          sections = [
            {
              pane = 1;
              section = "header";
              padding = 2;
            }
            # The "startup" section is lazy.nvim-specific: it calls
            # require("lazy.stats"), which does not exist under nvf's lz-n.
            {
              pane = 2;
              section = "keys";
              gap = 1;
              padding = 1;
            }
          ];
        };
        quickfile = {
          enabled = true;
        };
        statuscolumn = {
          enabled = true;
        };
      };
    };

    keymaps = [
      {
        key = "<leader>un";
        mode = "n";
        action = "function() local ok, noice = pcall(require, 'noice'); if ok then noice.cmd('dismiss') end end";
        lua = true;
        desc = "Dismiss all notifications";
      }
      {
        key = "<leader>E";
        mode = "n";
        action = "function() Snacks.explorer() end";
        lua = true;
        desc = "Explorer (Snacks)";
      }
      {
        key = "<leader>gg";
        mode = "n";
        action = "function() Snacks.lazygit() end";
        lua = true;
        desc = "Lazygit";
      }
      {
        key = "<leader>gl";
        mode = "n";
        action = "function() Snacks.lazygit.log() end";
        lua = true;
        desc = "Lazygit log (cwd)";
      }
    ];
  };
}
;
}
