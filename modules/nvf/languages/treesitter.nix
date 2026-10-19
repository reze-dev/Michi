{ ... }:
{
  flake.nvfModules.treesitter = { pkgs, ... }: {
  config.vim = {
    treesitter = {
      enable = true;
      # Bundles the tree-sitter CLI (wrapped with gcc on PATH) so
      # TSUpdateSync and custom parser compilation work.
      vendorCLI = true;
      autotagHtml = true;
      context.enable = false;

      # The source config never enables treesitter indentation; nvf would
      # turn it on for every filetype by default.
      indent.enable = false;

      # nvf's own highlighting autocmd has no big-file guard; the source
      # skips treesitter on buffers marked by the BigFile autocmd. That
      # autocmd is recreated below, so nvf's unguarded one stays off.
      highlight.enable = false;

      # Same parser set as `ensure_installed` in the source config. The
      # defaults (c/lua/vim/vimdoc/query) are all part of this list, so
      # there is no need to add them again.
      addDefaultGrammars = false;
      # NOTE: `jsonc` from the source list is not a parser of its own;
      # nvim-treesitter maps the jsonc filetype to the json parser.
      grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
        c
        cpp
        rust
        go
        gomod
        gowork
        gosum
        gotmpl
        llvm
        make
        cmake
        zig
        python
        lua
        luadoc
        luap
        javascript
        typescript
        tsx
        html
        css
        scss
        json
        json5
        yaml
        toml
        xml
        nix
        fish
        bash
        dockerfile
        hcl
        terraform
        markdown
        markdown_inline
        vimdoc
        vim
        regex
        query
        diff
        gitcommit
        gitignore
        git_rebase
        sql
        printf
      ];

      # Loads nvim-treesitter-textobjects. `select` stays off — mini.ai
      # provides the same queries with better coverage.
      textobjects.enable = true;
    };

    luaConfigRC.treesitter_start = ''
      vim.api.nvim_create_augroup("TreesitterStart", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "TreesitterStart",
        callback = function(args)
          if vim.b[args.buf].bigfile then
            return
          end
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    '';

    keymaps = [
      # ─── Textobjects: move ─────────────────────────────────────────────
      # nvim-treesitter's main branch does not generate keymaps from setup
      # options anymore; the same bindings are wired explicitly here.
      {
        key = "]f";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer') end";
        lua = true;
        desc = "Next function start";
      }
      {
        key = "]F";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer') end";
        lua = true;
        desc = "Next function end";
      }
      {
        key = "]c";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() if vim.wo.diff then vim.cmd('normal! ]c') return end require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer') end";
        lua = true;
        desc = "Next class start";
      }
      {
        key = "]C";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer') end";
        lua = true;
        desc = "Next class end";
      }
      {
        key = "]a";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() require('nvim-treesitter-textobjects.move').goto_next_start('@parameter.inner') end";
        lua = true;
        desc = "Next argument";
      }
      {
        key = "[f";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer') end";
        lua = true;
        desc = "Previous function start";
      }
      {
        key = "[F";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer') end";
        lua = true;
        desc = "Previous function end";
      }
      {
        key = "[c";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() if vim.wo.diff then vim.cmd('normal! [c') return end require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer') end";
        lua = true;
        desc = "Previous class start";
      }
      {
        key = "[C";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer') end";
        lua = true;
        desc = "Previous class end";
      }
      {
        key = "[a";
        mode = [
          "n"
          "x"
          "o"
        ];
        action = "function() require('nvim-treesitter-textobjects.move').goto_previous_start('@parameter.inner') end";
        lua = true;
        desc = "Previous argument";
      }

      # ─── Textobjects: swap ─────────────────────────────────────────────
      {
        key = "<leader>cx";
        mode = "n";
        action = "function() require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner') end";
        lua = true;
        desc = "Swap with next parameter";
      }
      {
        key = "<leader>cX";
        mode = "n";
        action = "function() require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner') end";
        lua = true;
        desc = "Swap with previous parameter";
      }

      # ─── Incremental selection ─────────────────────────────────────────
      # <C-space> expands the visual selection to the next treesitter node.
      {
        key = "<C-space>";
        mode = [
          "n"
          "x"
        ];
        action = ''
          function()
            local ok_ts, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
            if ok_ts and ts_utils and ts_utils.update_selection then
              ts_utils.update_selection(1)
              return
            end
            local node = vim.treesitter.get_node()
            if node then
              local srow, scol, erow, ecol = node:range()
              vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
              vim.cmd("normal! v")
              vim.api.nvim_win_set_cursor(0, { erow + 1, ecol - 1 })
            end
          end
        '';
        lua = true;
        desc = "Treesitter: incremental selection";
      }
    ];
  };
}
;
}
