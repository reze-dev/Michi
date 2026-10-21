{ ... }:
{
  michi.nvfModules.format = { pkgs, lib, ... }: {
    config.vim = {
      formatter.conform-nvim = {
        enable = true;
        presets = {
          clang-format.enable = true;
          rustfmt.enable = true;
          goimports.enable = true;
          gofumpt.enable = true;
          stylua.enable = true;
          taplo.enable = true;
          prettier.enable = true;
          nixfmt.enable = true;
          shfmt.enable = true;
          fish-indent.enable = true;
        };
        setupOpts = {
          formatters_by_ft = {
            c = [ "clang-format" ];
            cpp = [ "clang-format" ];
            rust = [ "rustfmt" ];
            go = [
              "goimports"
              "gofumpt"
            ];
            zig = [ "zigfmt" ];
            lua = [ "stylua" ];
            python = [
              "ruff_organize_imports"
              "ruff_format"
            ];
            toml = [ "taplo" ];
            javascript = [ "prettier" ];
            typescript = [ "prettier" ];
            javascriptreact = [ "prettier" ];
            typescriptreact = [ "prettier" ];
            html = [ "prettier" ];
            css = [ "prettier" ];
            scss = [ "prettier" ];
            json = [ "prettier" ];
            jsonc = [ "prettier" ];
            yaml = [ "prettier" ];
            "yaml.docker-compose" = [ "prettier" ];
            hcl = [ "terraform_fmt" ];
            terraform = [ "terraform_fmt" ];
            "terraform-vars" = [ "terraform_fmt" ];
            markdown = [ "prettier" ];
            graphql = [ "prettier" ];
            nix = [ "nixfmt" ];
            fish = [ "fish_indent" ];
            sh = [ "shfmt" ];
            bash = [ "shfmt" ];
            "_" = [ "trim_whitespace" ];
          };
          format_on_save = lib.mkLuaInline ''
            function(bufnr)
              -- Disable if buffer variable is set (toggle with :FormatToggle)
              if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
                return
              end
              -- Never auto-format commit messages
              local ft = vim.bo[bufnr].filetype
              if ft == "gitcommit" or ft == "gitrebase" then
                return
              end
              return {
                timeout_ms = 1000,
                lsp_format = "fallback",
              }
            end
          '';
          format_after_save = null;
          formatters = {
            shfmt = {
              prepend_args = [
                "-i"
                "2"
              ];
            };
            stylua = {
              prepend_args = [
                "--indent-type"
                "Spaces"
                "--indent-width"
                "2"
              ];
            };
            clang-format = {
              prepend_args = [ "-fallback-style=LLVM" ];
            };
            # Absolute commands for formatters nvf has no preset for, so the
            # binaries ship with the wrapper.
            zigfmt = {
              command = "${pkgs.zig}/bin/zig";
            };
            terraform_fmt = {
              command = "${pkgs.terraform}/bin/terraform";
            };
            ruff_format = {
              command = "${pkgs.ruff}/bin/ruff";
            };
            ruff_organize_imports = {
              command = "${pkgs.ruff}/bin/ruff";
            };
            fish_indent = {
              command = "${pkgs.fish}/bin/fish_indent";
            };
          };
        };
      };

      keymaps = [
        {
          key = "<leader>cf";
          mode = [
            "n"
            "v"
          ];
          action = "function() require('conform').format({ async = false, timeout_ms = 3000, lsp_format = 'fallback' }) end";
          lua = true;
          desc = "Format buffer/selection";
        }
      ];

      luaConfigRC.conform_commands = ''
        vim.api.nvim_create_user_command("FormatToggle", function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          local state = vim.g.disable_autoformat and "disabled" or "enabled"
          vim.notify("Autoformat " .. state, vim.log.levels.INFO)
        end, { desc = "Toggle autoformat on save" })

        vim.api.nvim_create_user_command("FormatToggleBuf", function()
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          local state = vim.b.disable_autoformat and "disabled" or "enabled"
          vim.notify("Autoformat (buffer) " .. state, vim.log.levels.INFO)
        end, { desc = "Toggle autoformat on save (buffer)" })
      '';
    };
  };
}
