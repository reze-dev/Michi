{ lib, ... }: {
  config.vim = {
    autocomplete = {
      nvim-cmp.enable = false;
      blink-cmp = {
        enable = true;
        friendly-snippets.enable = true;
        # nvf would otherwise inject its own <C-Space>/<CR>/<Tab>/… keymaps;
        # the standalone config defines the full table itself, so silence them.
        mappings = {
          complete = null;
          confirm = null;
          next = null;
          previous = null;
          close = null;
          scrollDocsUp = null;
          scrollDocsDown = null;
        };
        setupOpts = {
          keymap = {
            preset = "default";
            "<C-space>" = [
              "show"
              "show_documentation"
              "hide_documentation"
            ];
            "<C-e>" = [ "hide" ];
            "<CR>" = [
              "accept"
              "fallback"
            ];
            "<Tab>" = [
              "select_next"
              "snippet_forward"
              "fallback"
            ];
            "<S-Tab>" = [
              "select_prev"
              "snippet_backward"
              "fallback"
            ];
            "<C-j>" = [
              "select_next"
              "fallback"
            ];
            "<C-k>" = [
              "select_prev"
              "fallback"
            ];
            "<C-b>" = [
              "scroll_documentation_up"
              "fallback"
            ];
            "<C-f>" = [
              "scroll_documentation_down"
              "fallback"
            ];
          };
          appearance = {
            use_nvim_cmp_as_default = false;
            nerd_font_variant = "mono";
            kind_icons = {
              Text = "󰉿";
              Method = "󰊕";
              Function = "󰊕";
              Constructor = "󰒓";
              Field = "󰜢";
              Variable = "󰆦";
              Property = "󰖷";
              Class = "󱡠";
              Interface = "󱡠";
              Struct = "󱡠";
              Module = "󰅩";
              Unit = "󰪚";
              Value = "󰦨";
              Enum = "󰦨";
              EnumMember = "󰦨";
              Keyword = "󰻾";
              Constant = "󰏿";
              Snippet = "󱄽";
              Color = "󰏘";
              File = "󰈔";
              Reference = "󰬲";
              Folder = "󰉋";
              Event = "󱐋";
              Operator = "󰪚";
              TypeParameter = "󰬛";
            };
          };
          # sources.default is nvf-managed and already equals
          # [ "lsp" "path" "snippets" "buffer" ]; do not redefine it or the
          # list would be concatenated twice.
          completion = {
            accept = {
              auto_brackets = {
                enabled = true;
              };
            };
            menu = {
              border = "rounded";
              winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
              draw = {
                treesitter = [ "lsp" ];
                # Each column is a table of components with an optional `gap`
                # key; a Nix list cannot express the mixed array/key form, so
                # emit the Lua directly.
                columns = lib.mkLuaInline ''
                  {
                    { "kind_icon" },
                    { "label", "label_description", gap = 1 },
                    { "source_name" },
                  }
                '';
              };
            };
            documentation = {
              auto_show = true;
              auto_show_delay_ms = 200;
              window = {
                border = "rounded";
                winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder";
              };
            };
            ghost_text = {
              enabled = true;
            };
          };
          signature = {
            enabled = true;
            window = {
              border = "rounded";
            };
          };
          fuzzy = {
            implementation = "prefer_rust";
          };
        };
      };
    };
  };
}
