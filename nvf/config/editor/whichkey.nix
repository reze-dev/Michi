{ lib, ... }: {
  config.vim = {
    binds.whichKey = {
      enable = true;
      # Labels pushed down by nvf modules (added with which-key.add after
      # setup) that the source config does not have; null drops them.
      register = {
        "<leader>h" = null; # gitsigns
        "<leader>x" = null; # trouble (source spec defines this group)
        "<leader>lw" = null; # trouble
        "<leader>b" = null; # bufferline (source spec defines this group)
        "<leader>bm" = null; # bufferline
        "<leader>bs" = null; # bufferline
        "<leader>bsi" = null; # bufferline
        "<leader>a" = null; # harpoon (source spec defines this leaf)
      };
      setupOpts = {
        preset = "modern";
        delay = 300;
        icons = {
          breadcrumb = "»";
          separator = "➜";
          group = "+";
          mappings = true;
          rules = { };
        };
        # which-key's spec is a Lua array of tables with positional LHS plus
        # named fields; that shape cannot be expressed through toLuaObject.
        spec = lib.mkLuaInline ''
          {
            -- Top-level group prefixes
            { "<leader>f", group = "Find", icon = "" },
            { "<leader>b", group = "Buffer", icon = "󰓩 " },
            { "<leader>l", group = "LSP", icon = "" },
            { "<leader>c", group = "Code", icon = "󰅩 " },
            { "<leader>r", group = "Rust", icon = "󱘗 " },
            { "<leader>G", group = "Go", icon = "" },
            { "<leader>t", group = "Test", icon = "󰙨 " },
            { "<leader>d", group = "Debug", icon = "" },
            { "<leader>u", group = "UI/Toggles", icon = "󱄄 " },
            { "<leader>g", group = "Git", icon = "󰊢 " },
            { "<leader>x", group = "Trouble/Diagnostics", icon = "󰅙 " },
            { "<leader>s", group = "Search/Noice", icon = "󰎟 " },
            { "<leader>sn", group = "Noice", icon = "󰎟 " },
            { "<leader>q", group = "Session", icon = "󰩈 " },
            -- Leaf mappings with icons (oil/harpoon live here, not groups)
            { "<leader>e", icon = "󰙅 " },
            { "<leader>a", icon = "󰛢 " },
            { "<leader>w", icon = "󰆓 " },
            { "<leader>L", icon = "󰒲 " },
            -- Bracket groups
            { "[h", desc = "Harpoon prev", icon = "󰛢 " },
            { "]h", desc = "Harpoon next", icon = "󰛢 " },
            { "[b", desc = "Prev buffer", icon = "󰓩 " },
            { "]b", desc = "Next buffer", icon = "󰓩 " },
            { "[t", desc = "Prev TODO", icon = "󰍡 " },
            { "]t", desc = "Next TODO", icon = "󰍡 " },
            { "[T", desc = "Prev failed test", icon = "󰙨 " },
            { "]T", desc = "Next failed test", icon = "󰙨 " },
            { "[d", desc = "Prev diagnostic", icon = "󰅙 " },
            { "]d", desc = "Next diagnostic", icon = "󰅙 " },
            { "[e", desc = "Prev error", icon = "\u{F057} " },
            { "]e", desc = "Next error", icon = "\u{F057} " },
            { "[g", desc = "Prev git hunk", icon = "󰊢 " },
            { "]g", desc = "Next git hunk", icon = "󰊢 " },
            { "[q", desc = "Prev quickfix", icon = "󰁨 " },
            { "]q", desc = "Next quickfix", icon = "󰁨 " },
          }
        '';
        triggers = lib.mkLuaInline ''{ { "<auto>", mode = "nxsot" } }'';
        win = {
          border = "rounded";
          padding = [
            1
            2
          ];
          title = true;
          title_pos = "center";
          zindex = 1000;
        };
        layout = {
          width = {
            min = 20;
          };
          spacing = 3;
        };
        keys = {
          scroll_down = "<c-d>";
          scroll_up = "<c-u>";
        };
        show_help = true;
        show_keys = true;
      };
    };

    keymaps = [
      {
        key = "<leader>?";
        mode = "n";
        action = "function() require('which-key').show({ global = false }) end";
        lua = true;
        desc = "Buffer-local keymaps (which-key)";
      }
    ];
  };
}
