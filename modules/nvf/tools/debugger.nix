{ ... }:
{
  flake.nvfModules.debugger = { pkgs, ... }: let
  pythonWithDebugpy = pkgs.python3.withPackages (ps: [ ps.debugpy ]);
in {
  config.vim = {
    debugger.nvim-dap = {
      enable = true;
      # Upstream uses nvim-dap-view, not the archived nvim-dap-ui.
      ui.enable = false;
      # Every nivo default mapping is replaced by the keymaps below.
      mappings = {
        continue = null;
        restart = null;
        terminate = null;
        runLast = null;
        toggleRepl = null;
        hover = null;
        toggleBreakpoint = null;
        runToCursor = null;
        stepInto = null;
        stepOut = null;
        stepOver = null;
        stepBack = null;
        goUp = null;
        goDown = null;
        toggleDapUI = null;
      };
    };

    extraPlugins = with pkgs.vimPlugins; {
      nvim-dap-view = {
        package = nvim-dap-view;
      };
      nvim-dap-virtual-text = {
        package = nvim-dap-virtual-text;
      };
      nvim-dap-python = {
        package = nvim-dap-python;
      };
    };

    keymaps = [
      {
        key = "<leader>db";
        mode = "n";
        action = "function() require('dap').toggle_breakpoint() end";
        lua = true;
        desc = "DAP: toggle breakpoint";
      }
      {
        key = "<leader>dB";
        mode = "n";
        action = "function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end";
        lua = true;
        desc = "DAP: conditional breakpoint";
      }
      {
        key = "<leader>dc";
        mode = "n";
        action = "function() require('dap').continue() end";
        lua = true;
        desc = "DAP: continue";
      }
      {
        key = "<leader>dC";
        mode = "n";
        action = "function() require('dap').run_to_cursor() end";
        lua = true;
        desc = "DAP: run to cursor";
      }
      {
        key = "<leader>di";
        mode = "n";
        action = "function() require('dap').step_into() end";
        lua = true;
        desc = "DAP: step into";
      }
      {
        key = "<leader>do";
        mode = "n";
        action = "function() require('dap').step_over() end";
        lua = true;
        desc = "DAP: step over";
      }
      {
        key = "<leader>dO";
        mode = "n";
        action = "function() require('dap').step_out() end";
        lua = true;
        desc = "DAP: step out";
      }
      {
        key = "<leader>dp";
        mode = "n";
        action = "function() require('dap').pause() end";
        lua = true;
        desc = "DAP: pause";
      }
      {
        key = "<leader>dr";
        mode = "n";
        action = "function() require('dap').restart() end";
        lua = true;
        desc = "DAP: restart";
      }
      {
        key = "<leader>dl";
        mode = "n";
        action = "function() require('dap').run_last() end";
        lua = true;
        desc = "DAP: run last";
      }
      {
        key = "<leader>dt";
        mode = "n";
        action = "function() require('dap').terminate() end";
        lua = true;
        desc = "DAP: terminate";
      }
      {
        key = "<leader>dw";
        mode = "n";
        action = "function() require('dap.ui.widgets').hover() end";
        lua = true;
        desc = "DAP: widgets";
      }
      {
        key = "<leader>du";
        mode = "n";
        action = "<cmd>DapViewToggle<cr>";
        desc = "DAP: toggle UI";
      }
      {
        key = "<leader>de";
        mode = [
          "n"
          "v"
        ];
        action = "function() require('dap-view').add_expr() end";
        lua = true;
        desc = "DAP: eval";
      }
    ];

    luaConfigRC.dap_setup = ''
      local ok_dap, dap = pcall(require, "dap")
      if ok_dap then
        -- Signs
        vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnosticError", linehl = "", numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
        vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DiagnosticError", linehl = "", numhl = "" })
        vim.fn.sign_define("DapLogPoint", { text = "\u{25C6} ", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
        vim.fn.sign_define("DapStopped", { text = "\u{25B6} ", texthl = "DiagnosticOk", linehl = "DapStoppedLine", numhl = "" })
        vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

        -- DAP View (modern UI replacing the archived dap-ui)
        local ok_dap_view, dap_view = pcall(require, "dap-view")
        if ok_dap_view then
          dap_view.setup({
            winbar = { show = true },
            -- The source's `height = 12` was renamed to `size` upstream
            -- (nvim-dap-view >= 1.0); values above 1 are absolute lines.
            windows = { size = 12 },
            auto_toggle = true,
          })
        end

        -- DAP Virtual Text
        local ok_dap_vt, dap_vt = pcall(require, "nvim-dap-virtual-text")
        if ok_dap_vt then
          dap_vt.setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            only_first_definition = true,
            all_references = false,
            clear_on_continue = false,
            display_callback = function(variable, buf, stackframe, node, options)
              if options.virt_text_pos == "inline" then
                return " = " .. variable.value
              else
                return variable.name .. " = " .. variable.value
              end
            end,
            virt_text_pos = "eol",
            all_frames = false,
            virt_lines = false,
            virt_text_win_col = nil,
          })
        end

        -- DAP Python
        local ok_dap_py, dap_py = pcall(require, "dap-python")
        if ok_dap_py then
          local debugpy_python = "${pythonWithDebugpy}/bin/python3"
          dap_py.setup(
            vim.fn.filereadable(debugpy_python) == 1 and debugpy_python or vim.fn.exepath("python3")
          )
        end

        -- CodeLLDB Discovery & Adapter
        local codelldb_pkg = "${pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter}/bin/codelldb"
        local liblldb_pkg = "${pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter}/share/lldb/lib/liblldb.so"
        local codelldb_cmd = "codelldb"

        if vim.fn.executable(codelldb_pkg) == 1 then
          codelldb_cmd = codelldb_pkg
        elseif vim.fn.executable("codelldb") == 1 then
          codelldb_cmd = vim.fn.exepath("codelldb")
        end

        local codelldb_args = { "--port", "''${port}" }
        if vim.fn.filereadable(liblldb_pkg) == 1 then
          table.insert(codelldb_args, 1, "--liblldb")
          table.insert(codelldb_args, 2, liblldb_pkg)
        end

        dap.adapters.codelldb = {
          type = "server",
          port = "''${port}",
          executable = {
            command = codelldb_cmd,
            args = codelldb_args,
          },
        }
        -- Clone (don't share the table — dap mutates per launch)
        dap.adapters.lldb = vim.tbl_extend("force", {}, dap.adapters.codelldb)

        -- Executable Discovery & Selection Helper
        local function get_binary()
          local cwd = vim.fn.getcwd()
          local candidates = {}
          local seen = {}

          local search_dirs = {
            "target/debug", "target/release", "build", "build/bin",
            "bin", "out", "cmake-build-debug", "cmake-build-release",
          }
          local ignored_exts = {
            o = true, a = true, so = true, dylib = true, dll = true,
            d = true, rlib = true, rmeta = true, pdb = true,
            txt = true, log = true, cmake = true, json = true,
            ninja = true, lock = true,
          }
          local ignored_script_exts = {
            sh = true, bash = true, zsh = true, lua = true, py = true,
            pl = true, rb = true, js = true, ts = true, md = true,
          }

          for _, dir in ipairs(search_dirs) do
            local full_dir = cwd .. "/" .. dir
            if vim.fn.isdirectory(full_dir) == 1 then
              local files = vim.fn.glob(full_dir .. "/*", false, true)
              for _, file in ipairs(files) do
                if vim.fn.isdirectory(file) == 0 and vim.fn.executable(file) == 1 then
                  local ext = vim.fn.fnamemodify(file, ":e"):lower()
                  if not ignored_exts[ext] and not ignored_script_exts[ext] and not seen[file] then
                    seen[file] = true
                    table.insert(candidates, file)
                  end
                end
              end
            end
          end

          local root_files = vim.fn.glob(cwd .. "/*", false, true)
          for _, file in ipairs(root_files) do
            if vim.fn.isdirectory(file) == 0 and vim.fn.executable(file) == 1 then
              local ext = vim.fn.fnamemodify(file, ":e"):lower()
              if not ignored_exts[ext] and not ignored_script_exts[ext] and not file:match("/%.") and not seen[file] then
                seen[file] = true
                table.insert(candidates, file)
              end
            end
          end

          -- Single candidate: return immediately, no picker, no prompt.
          if #candidates == 1 then
            return candidates[1]
          end

          local co = coroutine.running()
          if co and #candidates > 0 then
            local items = {}
            for _, c in ipairs(candidates) do
              table.insert(items, c)
            end
            table.insert(items, "Manually enter path...")

            vim.ui.select(items, {
              prompt = "Select executable: ",
              format_item = function(item)
                if item == "Manually enter path..." then
                  return item
                end
                return vim.fn.fnamemodify(item, ":.")
              end,
            }, function(choice)
              if not choice then
                coroutine.resume(co, dap.ABORT)
              elseif choice == "Manually enter path..." then
                local manual = vim.fn.input("Path to executable: ", cwd .. "/", "file")
                coroutine.resume(co, manual ~= "" and manual or dap.ABORT)
              else
                coroutine.resume(co, choice)
              end
            end)
            return coroutine.yield()
          else
            local input = vim.fn.input("Path to executable: ", cwd .. "/", "file")
            if input == "" then
              return dap.ABORT or nil
            end
            return input
          end
        end

        -- C / C++ / Rust Launch Configurations
        local function codelldb_configs()
          return {
            {
              name = "Launch Binary (Smart Picker)",
              type = "codelldb",
              request = "launch",
              program = get_binary,
              cwd = "''${workspaceFolder}",
              stopOnEntry = false,
              args = {},
            },
            {
              name = "Launch Binary with Arguments",
              type = "codelldb",
              request = "launch",
              program = get_binary,
              cwd = "''${workspaceFolder}",
              stopOnEntry = false,
              args = function()
                local args_str = vim.fn.input("Arguments: ")
                if args_str == "" then
                  return {}
                end
                return vim.split(args_str, "%s+", { trimempty = true })
              end,
            },
            {
              name = "Attach to Process",
              type = "codelldb",
              request = "attach",
              pid = function()
                return require("dap.utils").pick_process()
              end,
              cwd = "''${workspaceFolder}",
            },
            {
              name = "Load Core Dump",
              type = "codelldb",
              request = "attach",
              program = get_binary,
              coreDumpPath = function()
                local core_path = vim.fn.input("Path to core dump: ", vim.fn.getcwd() .. "/", "file")
                return core_path ~= "" and core_path or nil
              end,
              cwd = "''${workspaceFolder}",
            },
          }
        end

        -- Deep-copied per filetype so per-launch mutations don't leak across ft
        dap.configurations.cpp = codelldb_configs()
        dap.configurations.c = codelldb_configs()
        dap.configurations.rust = codelldb_configs()

        -- Delve (Go) Adapter & Configurations
        local dlv_pkg = "${pkgs.delve}/bin/dlv"
        local dlv_path = "dlv"
        if vim.fn.executable(dlv_pkg) == 1 then
          dlv_path = dlv_pkg
        elseif vim.fn.executable("dlv") == 1 then
          dlv_path = vim.fn.exepath("dlv")
        end

        dap.adapters.delve = {
          type = "server",
          port = "''${port}",
          executable = {
            command = dlv_path,
            args = { "dap", "-l", "127.0.0.1:''${port}" },
          },
        }
        dap.adapters.go = dap.adapters.delve

        dap.configurations.go = {
          {
            type = "delve",
            name = "Debug (Smart Picker / Current File)",
            request = "launch",
            program = "''${file}",
          },
          {
            type = "delve",
            name = "Debug Package",
            request = "launch",
            program = "''${fileDirname}",
          },
          {
            type = "delve",
            name = "Debug with Arguments",
            request = "launch",
            program = "''${file}",
            args = function()
              local args_str = vim.fn.input("Arguments: ")
              if args_str == "" then
                return {}
              end
              return vim.split(args_str, "%s+", { trimempty = true })
            end,
          },
          {
            type = "delve",
            name = "Debug Test",
            request = "launch",
            mode = "test",
            program = "''${file}",
          },
          {
            type = "delve",
            name = "Debug Test (Package)",
            request = "launch",
            mode = "test",
            program = "./''${relativeFileDirname}",
          },
          {
            type = "delve",
            name = "Attach to Process",
            request = "attach",
            mode = "local",
            processId = function()
              return require("dap.utils").pick_process()
            end,
          },
        }
      end
    '';
  };
}
;
}
