{ ... }:
{
  michi.nvfModules.languages = { pkgs, lib, ... }: {
    config.vim = {
      # ─── nvf language modules ──────────────────────────────────────────
      # Only the rust module is enabled, and solely for its rustaceanvim
      # extension. The source config wires every language by hand:
      #   * servers live in lsp.nix (canonical Neovim 0.11+ names, no
      #     nvf presets — those use different names, e.g. `lua-language-server`
      #     instead of `lua_ls`, which would start duplicate clients),
      #   * formatting is owned by conform (editor/format.nix),
      #   * DAP is owned by tools/debugger.nix,
      #   * grammars are listed in treesitter.nix.
      languages.rust = {
        enable = true;
        lsp.enable = false;
        format.enable = false;
        dap.enable = false;
        treesitter.enable = false;

        extensions.rustaceanvim = {
          enable = true;
          # The setup is a faithful port of the source `vim.g.rustaceanvim`.
          # `dap` is left at the nvf default, which is the same codelldb
          # adapter the source auto-detected, but wired to the nixpkgs
          # package. nvf renders this as a function (rustaceanvim >= 6 API).
          setupOpts = {
            tools = {
              hover_actions.replace_builtin_hover = false;
              float_win_config.border = "rounded";
            };
            server = {
              # rustaceanvim does not pick the command up from
              # vim.lsp.config, so it is set explicitly (nvf default).
              cmd = [ (lib.getExe pkgs.rust-analyzer) ];
              # `capabilities` is the local blink.cmp-backed table created
              # in pluginRC.lsp-setup.
              capabilities = lib.mkLuaInline ''
                (function()
                  local ok, blink = pcall(require, "blink.cmp")
                  if ok then
                    return blink.get_lsp_capabilities()
                  end
                  return capabilities or vim.lsp.protocol.make_client_capabilities()
                end)()
              '';
              on_attach = lib.mkLuaInline ''
                function(client, bufnr)
                  -- Common LSP keymaps are handled by the LspAttach autocommand in lsp.nix.
                  -- Here we only add Rust-specific keymaps
                  local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Rust: " .. desc })
                  end

                  map("<leader>re", "<cmd>RustLsp expandMacro<cr>", "Expand macro")
                  map("<leader>rc", "<cmd>RustLsp openCargo<cr>", "Open Cargo.toml")
                  map("<leader>rp", "<cmd>RustLsp parentModule<cr>", "Parent module")
                  map("<leader>rd", "<cmd>RustLsp renderDiagnostic<cr>", "Render diagnostic")
                  map("<leader>rr", "<cmd>RustLsp runnables<cr>", "Runnables")
                  map("<leader>rt", "<cmd>RustLsp testables<cr>", "Testables")
                  map("<leader>rm", "<cmd>RustLsp rebuildProcMacros<cr>", "Rebuild proc macros")
                  map("<leader>rk", "<cmd>RustLsp moveItem up<cr>", "Move item up")
                  map("<leader>rj", "<cmd>RustLsp moveItem down<cr>", "Move item down")
                  map("<leader>ra", "<cmd>RustLsp codeAction<cr>", "Code action (rust)")
                  map("<leader>rh", "<cmd>RustLsp hover actions<cr>", "Hover actions")
                  map("<leader>rJ", "<cmd>RustLsp joinLines<cr>", "Join lines (Rust)")

                  -- Debugging
                  map("<leader>rD", "<cmd>RustLsp debuggables<cr>", "Debuggables")
                end
              '';
              default_settings = {
                "rust-analyzer" = {
                  cargo = {
                    allFeatures = true;
                    loadOutDirsFromCheck = true;
                    buildScripts = {
                      enable = true;
                    };
                  };
                  check = {
                    enable = true;
                    command = "clippy";
                    extraArgs = [ "--no-deps" ];
                  };
                  procMacro = {
                    enable = true;
                    ignored = {
                      "async-trait" = [ "async_trait" ];
                      "napi-derive" = [ "napi" ];
                      "async-recursion" = [ "async_recursion" ];
                    };
                  };
                  inlayHints = {
                    bindingModeHints = {
                      enable = false;
                    };
                    chainingHints = {
                      enable = true;
                    };
                    closingBraceHints = {
                      enable = true;
                      minLines = 25;
                    };
                    closureReturnTypeHints = {
                      enable = "with_block";
                    };
                    lifetimeElisionHints = {
                      enable = "never";
                    };
                    maxLength = 25;
                    parameterHints = {
                      enable = true;
                    };
                    reborrowHints = {
                      enable = "never";
                    };
                    renderColons = true;
                    typeHints = {
                      enable = true;
                      hideClosureInitialization = false;
                      hideNamedConstructor = false;
                    };
                  };
                };
              };
            };
          };
        };
      };

      # ─── Plugins the source config loads for languages ─────────────────
      extraPlugins = with pkgs.vimPlugins; {
        clangd_extensions-nvim = {
          package = clangd_extensions-nvim;
        };
        go-nvim = {
          package = go-nvim;
        };
        guihua-lua = {
          package = guihua-lua;
        };
      };

      luaConfigRC.language_tools = ''
        -- ─── Clangd Extensions ─────────────────────────────────────────────
        require("clangd_extensions").setup({
          ast = {
            role_icons = {
              type = "\u{1F123}",
              declaration = "\u{1F113}",
              expression = "\u{1F114}",
              statement = ";",
              specifier = "\u{1F122}",
              ["template argument"] = "\u{1F183}",
            },
            kind_icons = {
              Compound = "\u{1F132}",
              Recovery = "\u{1F141}",
              TranslationUnit = "\u{1F144}",
              PackExpansion = "\u{1F13F}",
              TemplateTypeParm = "\u{1F143}",
              TemplateTemplateParm = "\u{1F143}",
              TemplateParamObject = "\u{1F143}",
            },
            highlights = {
              detail = "Comment",
            },
          },
          memory_usage = {
            border = "rounded",
          },
          symbol_info = {
            border = "rounded",
          },
        })

        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("ClangdKeymaps", { clear = true }),
          pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
          callback = function(event)
            local map = function(keys, func, desc)
              vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "Clangd: " .. desc })
            end

            map("<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch source/header")
            map("<leader>ct", "<cmd>ClangdTypeHierarchy<cr>", "Type hierarchy")
            map("<leader>cm", "<cmd>ClangdMemoryUsage<cr>", "Memory usage")
            map("<leader>cs", "<cmd>ClangdSymbolInfo<cr>", "Symbol info")
            map("<leader>cA", "<cmd>ClangdAST<cr>", "View AST")
          end,
        })

        -- ─── Go Support ────────────────────────────────────────────────────
        require("go").setup({
          -- Disable LSP here — we configure gopls in lsp.nix
          lsp_cfg = false,
          lsp_on_attach = false,
          -- Formatting is owned by conform.nvim (one formatter on save).
          gofmt = "gofumpt",
          goimports = "gopls",
          -- Linting
          linter = "golangci-lint",
          -- Testing (neotest-golang is the primary runner; GoTest is the fallback)
          test_runner = "go",
          run_in_floaterm = false,
          -- DAP — owned by debugger.nix (delve adapter + configurations).
          dap_debug = false,
          -- Tags
          tag_transform = "snakecase",
          tag_options = "json=omitempty",
          -- Misc
          verbose = false,
          log_path = vim.fn.stdpath("cache") .. "/gonvim.log",
          icons = { breakpoint = "\u{F057} ", currentpos = "\u{25B6} " },
        })

        -- Go-specific keymaps
        local go_keys = vim.api.nvim_create_augroup("GoKeymaps", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
          group = go_keys,
          pattern = { "go" },
          callback = function(event)
            local map = function(keys, func, desc)
              vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "Go: " .. desc })
            end

            map("<leader>Gt", "<cmd>GoTest<cr>", "Run tests")
            map("<leader>Gf", "<cmd>GoTestFunc<cr>", "Test function")
            map("<leader>Gc", "<cmd>GoCoverage<cr>", "Toggle coverage")
            map("<leader>Ga", "<cmd>GoAddTag<cr>", "Add struct tags")
            map("<leader>Gr", "<cmd>GoRmTag<cr>", "Remove struct tags")
            map("<leader>Gi", "<cmd>GoImpl<cr>", "Implement interface")
            map("<leader>Ge", "<cmd>GoIfErr<cr>", "Generate if err")
            map("<leader>Gd", function() require("dap").continue() end, "Start debugger")
            map("<leader>GD", function() require("dap").terminate() end, "Stop debugger")
            map("<leader>Gl", "<cmd>GoLint<cr>", "Lint")
            map("<leader>Gv", "<cmd>GoVet<cr>", "Vet")
            map("<leader>Gg", "<cmd>GoGenerate<cr>", "Go generate")
            map("<leader>Gm", "<cmd>GoModTidy<cr>", "Go mod tidy")
          end,
        })
      '';
    };
  };
}
