{ ... }:
{
  flake.nvfModules.editing = { pkgs, lib, ... }: {
  config.vim = {
    autopairs.nvim-autopairs = {
      enable = true;
      setupOpts = {
        check_ts = true;
        ts_config = {
          lua = [
            "string"
            "source"
          ];
          javascript = [
            "string"
            "template_string"
          ];
          java = false;
        };
        disable_filetype = [
          "snacks_picker_input"
          "TelescopePrompt"
          "spectre_panel"
        ];
        fast_wrap = {
          map = "<M-e>";
          chars = [
            "{"
            "["
            "("
            "\""
            "'"
          ];
          pattern = ''[%'%"%>%]%)%}%,]'';
          end_key = "$";
          before_key = "h";
          after_key = "l";
          cursor_pos_before = true;
          keys = "qwertyuiopzxcvbnmasdfghjkl";
          manual_position = true;
          highlight = "Search";
          highlight_grey = "Comment";
        };
      };
    };

    # mini.surround (source), not nvim-surround (vim.utility.surround)
    mini.surround = {
      enable = true;
      setupOpts = {
        mappings = {
          add = "ys";
          delete = "ds";
          replace = "cs";
          find = "sf";
          find_left = "sF";
          highlight = "sh";
          suffix_last = "l";
          suffix_next = "n";
        };
      };
    };

    mini.ai = {
      enable = true;
      setupOpts = {
        n_lines = 500;
        custom_textobjects = lib.mkLuaInline ''
          (function()
            local ai = require("mini.ai")
            return {
              o = ai.gen_spec.treesitter({
                a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                i = { "@block.inner", "@conditional.inner", "@loop.inner" },
              }, {}),
              f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
              c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
              a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
              l = ai.gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }, {}),
              b = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }, {}),
            }
          end)()
        '';
      };
    };

    extraPlugins = with pkgs.vimPlugins; {
      persistence-nvim = {
        package = persistence-nvim;
        setup = ''
          require("persistence").setup({
            options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
          })
        '';
      };
    };

    keymaps = [
      {
        key = "<leader>qs";
        mode = "n";
        action = "function() require('persistence').load() end";
        lua = true;
        desc = "Restore session";
      }
      {
        key = "<leader>ql";
        mode = "n";
        action = "function() require('persistence').load({ last = true }) end";
        lua = true;
        desc = "Restore last session";
      }
      {
        key = "<leader>qd";
        mode = "n";
        action = "function() require('persistence').stop() end";
        lua = true;
        desc = "Don't save current session";
      }
    ];
  };
}
;
}
