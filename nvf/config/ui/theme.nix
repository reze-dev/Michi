{ pkgs, ... }: {
  config.vim = {
    extraPlugins = with pkgs.vimPlugins; {
      base46 = {
        package = pkgs.vimUtils.buildVimPlugin {
          name = "base46";
          src = pkgs.fetchFromGitHub {
            owner = "AvengeMedia";
            repo = "base46";
            rev = "83522e02c6c3b4ea901c4bffd9e0a5e0371c1fe6";
            hash = "sha256-kwDMC6rYzJYECmGnwn8JiAbffUq7hAXcUH6gPSkk2uI=";
          };
          doCheck = false;
        };
      };
      rose-pine = {
        package = rose-pine;
      };
    };

    luaConfigRC.theme_setup = ''
      local ok_rp, rose_pine = pcall(require, "rose-pine")
      if ok_rp then
        rose_pine.setup({
          variant = "main",
          dark_variant = "main",
          dim_inactive_windows = false,
          extend_background_behind_borders = true,
          styles = {
            bold = true,
            italic = true,
            transparency = true,
          },
          highlight_groups = {
            SnacksPickerList = { bg = "none" },
            SnacksPickerInput = { bg = "none" },
            FloatBorder = { fg = "highlight_high", bg = "surface" },
            NormalFloat = { bg = "surface" },
            CursorLine = { bg = "highlight_low" },
            CursorLineNr = { fg = "gold" },
            StatusLine = { fg = "love", bg = "love", blend = 10 },
            StatusLineNC = { fg = "subtle", bg = "surface" },
            WhichKeyFloat = { bg = "surface" },
          },
        })
      end

      local ok_base46, base46 = pcall(require, "base46")
      if ok_base46 then
        base46.setup({
          transparency = true,
          set_background = true,
          term_colors = true,
          integrations = {
            defaults = true,
            syntax = true,
            treesitter = true,
            lsp = true,
            whichkey = true,
            gitsigns = true,
            bufferline = true,
            devicons = true,
            blink = true,
            statusline = false,
            neotest = true,
          },
        })
      end

      package.preload["core.theme"] = function()
        local base46_state_file = vim.fn.stdpath("state") .. "/base46-theme"
        return {
          base46_state_file = base46_state_file,
          read_base46_theme = function()
            if vim.fn.filereadable(base46_state_file) ~= 1 then return nil end
            local lines = vim.fn.readfile(base46_state_file)
            local theme = lines[1]
            return theme and theme ~= "" and theme or nil
          end,
          write_base46_theme = function(theme)
            vim.fn.mkdir(vim.fn.fnamemodify(base46_state_file, ":h"), "p")
            vim.fn.writefile({ theme }, base46_state_file)
          end,
        }
      end

      local theme_state = require("core.theme")
      local saved_theme = theme_state.read_base46_theme()

      local function apply_theme(choice)
        if choice == "rose-pine" then
          vim.cmd.colorscheme("rose-pine")
        else
          local ok, b46 = pcall(require, "base46")
          if ok then
            b46.load(choice)
            vim.api.nvim_exec_autocmds("ColorScheme", {})
          else
            vim.cmd.colorscheme("rose-pine")
          end
        end
      end

      local saved_theme = theme_state.read_base46_theme()
      apply_theme(saved_theme or "rose-pine")

      local function pick_theme()
        local themes = { "rose-pine" }
        for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/base46/themes/*.lua", true)) do
          local name = vim.fn.fnamemodify(path, ":t:r")
          themes[#themes + 1] = name
        end
        table.sort(themes)

        vim.ui.select(themes, { prompt = "Select theme: " }, function(choice)
          if choice then
            require("core.theme").write_base46_theme(choice)
            apply_theme(choice)
            vim.notify("Theme: " .. choice, vim.log.levels.INFO)
          end
        end)
      end

      vim.keymap.set("n", "<leader>ut", pick_theme, { desc = "Themes: choose theme" })
      vim.api.nvim_create_user_command("NvChadTheme", pick_theme, { desc = "Choose colorscheme" })
      package.preload["base46-themes"] = function()
        return {
          pick = pick_theme,
        }
      end
    '';
  };
}
