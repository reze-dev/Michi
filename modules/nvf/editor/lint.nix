{ ... }:
{
  michi.nvfModules.lint = { pkgs, lib, ... }: {
  config.vim = {
    diagnostics = {
      presets = {
        golangci-lint.enable = true;
        hadolint.enable = true;
      };
      nvim-lint = {
        enable = true;
        # Custom autocmds below (BufWritePost/BufReadPost/InsertLeave) replace
        # nvf's BufWritePost-only hook.
        lint_after_save = false;
        linters = {
          # NOTE: c/cpp are intentionally absent — clangd --clang-tidy already
          # reports them; running nvim-lint clang-tidy too = duplicates.
          ruff.cmd = "${pkgs.ruff}/bin/ruff";
          yamllint.cmd = "${pkgs.yamllint}/bin/yamllint";
          tflint.cmd = "${pkgs.tflint}/bin/tflint";
        };
        linters_by_ft = {
          go = [ "golangci-lint" ];
          python = [ "ruff" ];
          yaml = [ "yamllint" ];
          "yaml.docker-compose" = [ "yamllint" ];
          dockerfile = [ "hadolint" ];
          terraform = [ "tflint" ];
          "terraform-vars" = [ "tflint" ];
          hcl = [ "tflint" ];
        };
      };
    };

    augroups = [
      {
        name = "NvimLint";
        clear = true;
      }
    ];

    autocmds = [
      {
        event = [
          "BufWritePost"
          "BufReadPost"
          "InsertLeave"
        ];
        group = "NvimLint";
        callback = lib.mkLuaInline ''
          function(args)
            if vim.api.nvim_buf_is_valid(args.buf) then
              pcall(nvf_lint, args.buf)
            end
          end
        '';
        desc = "Lint current buffer";
      }
    ];

    luaConfigRC.lint_command = ''
      vim.api.nvim_create_user_command("Lint", function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_is_valid(buf) then
          pcall(nvf_lint, buf)
        end
      end, { desc = "Trigger linting for current buffer" })
    '';

    keymaps = [
      {
        key = "<leader>cl";
        mode = "n";
        action = "<cmd>Lint<cr>";
        desc = "Lint current buffer";
      }
    ];
  };
}
;
}
