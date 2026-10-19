{ ... }:
{
  michi.nvfModules.theme = { pkgs, ... }: {
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
    };

    luaConfigRC.theme_setup = ''
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
        local M = {}
        M.base46_state_file = vim.fn.stdpath("state") .. "/base46-theme"

        function M.read_base46_theme()
          if vim.fn.filereadable(M.base46_state_file) ~= 1 then
            return nil
          end

          local lines = vim.fn.readfile(M.base46_state_file)
          local theme = lines[1]
          if type(theme) == "string" then
            theme = vim.trim(theme)
          end
          return theme and theme ~= "" and theme or nil
        end

        function M.write_base46_theme(theme)
          if type(theme) ~= "string" or theme == "" then
            return false
          end
          local dir = vim.fn.fnamemodify(M.base46_state_file, ":h")
          if not vim.uv.fs_stat(dir) then
            vim.fn.mkdir(dir, "p")
          end
          return vim.fn.writefile({ theme }, M.base46_state_file) == 0
        end

        return M
      end

      local ok_state, theme_state = pcall(require, "core.theme")

      local function theme_names()
        local names = {}
        for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/base46/themes/*.lua", true)) do
          local name = vim.fn.fnamemodify(path, ":t:r")
          names[#names + 1] = name
        end
        table.sort(names)
        return names
      end

      local function apply_theme(name)
        base46.load(name)
      end

      local function sync_notify_bg()
        local bg = nil
        local ok_base, base46_mod = pcall(require, "base46")
        if ok_base then
          local ok, colors = pcall(function()
            return base46_mod.theme_tables[base46_mod.current_theme].base_30
          end)
          if ok and type(colors) == "table" then
            bg = colors.darker_black or colors.black
          end
          if not bg and base46_mod.get_builtin_theme and base46_mod.current_theme then
            local ok2, theme = pcall(base46_mod.get_builtin_theme, base46_mod.current_theme)
            if ok2 and type(theme) == "table" then
              local b30 = theme.base_30 or {}
              bg = b30.darker_black or b30.black
            end
          end
        end
        if not bg then
          local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
          bg = normal.bg
        end
        if not bg then
          local nf = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
          bg = nf.bg
        end
        if type(bg) == "number" then
          bg = ("#%06x"):format(bg)
        end
        if type(bg) ~= "string" or bg == "" then
          bg = "#1e1e2e"
        end
        vim.api.nvim_set_hl(0, "NotifyBackground", { bg = bg })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("ThemeNotifyBackground", { clear = true }),
        callback = sync_notify_bg,
      })

      package.preload["base46-themes"] = function()
        return {
          pick = function()
            vim.ui.select(theme_names(), { prompt = "NvChad theme" }, function(choice)
              if choice then
                theme_state.write_base46_theme(choice)
                apply_theme(choice)
                vim.notify("Theme: " .. choice, vim.log.levels.INFO)
              end
            end)
          end,
        }
      end

      if not ok_state then
        apply_theme("rosepine")
      else
        local saved_theme = theme_state.read_base46_theme()
        apply_theme(saved_theme or "rosepine")
      end
      vim.schedule(sync_notify_bg)

      vim.keymap.set("n", "<leader>ut", function()
        require("base46-themes").pick()
      end, { desc = "Themes: choose NvChad theme" })

      vim.api.nvim_create_user_command("NvChadTheme", function()
        require("base46-themes").pick()
      end, { desc = "Choose an NvChad Base46 colorscheme" })
    '';
  };
}
;
}
