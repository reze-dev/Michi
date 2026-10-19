{ lib, ... }: {
  config.vim = {
    lsp = {
      enable = true;

      # Neovim 0.12 no longer ships the bundled lsp/*.lua server configs;
      # the source relied on nvim-lspconfig for cmd/filetypes/root_markers.
      # The plugin puts those back on the runtimepath, so the servers below
      # (which use the same canonical lspconfig names as the source) only
      # need their settings.
      lspconfig.enable = true;

      # Every mapping nvf's default_on_attach would create is replaced by the
      # source's own LspAttach handler below.
      mappings = {
        goToDefinition = null;
        goToDeclaration = null;
        goToType = null;
        listImplementations = null;
        listReferences = null;
        nextDiagnostic = null;
        previousDiagnostic = null;
        openDiagnosticFloat = null;
        documentHighlight = null;
        listDocumentSymbols = null;
        addWorkspaceFolder = null;
        removeWorkspaceFolder = null;
        listWorkspaceFolders = null;
        listWorkspaceSymbols = null;
        hover = null;
        signatureHelp = null;
        renameSymbol = null;
        codeAction = null;
        format = null;
        toggleFormatOnSave = null;
      };

      trouble = {
        enable = true;
        # The source passes no options to trouble's setup.
        setupOpts = { };
        # Trouble's own defaults would add <leader>l*/x* bindings that the
        # source config does not have; its keymaps live in the block below.
        mappings = {
          workspaceDiagnostics = null;
          documentDiagnostics = null;
          lspReferences = null;
          quickfix = null;
          locList = null;
          symbols = null;
        };
      };

      servers = {
        # C/C++
        clangd = {
          capabilities = lib.mkLuaInline ''
            vim.tbl_deep_extend("force", capabilities, {
              offsetEncoding = { "utf-16", "utf-8" },
            })
          '';
          cmd = [
            "clangd"
            "--background-index"
            "--clang-tidy"
            "--header-insertion=iwyu"
            "--completion-style=detailed"
            "--function-arg-placeholders"
            "--fallback-style=llvm"
            "--pch-storage=memory"
          ];
          init_options = {
            usePlaceholders = true;
            completeUnimported = true;
            clangdFileStatus = true;
          };
        };

        # Lua
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT"; };
              workspace = {
                checkThirdParty = false;
                library = lib.mkLuaInline ''{ vim.env.VIMRUNTIME, "''${3rd}/luv/library" }'';
              };
              completion = { callSnippet = "Replace"; };
              diagnostics = { globals = [ "vim" ]; };
              telemetry = { enable = false; };
              hint = { enable = true; };
            };
          };
        };

        # Python
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard";
                autoImportCompletions = true;
                diagnosticSeverityOverrides = {
                  reportUnusedImport = "information";
                  reportUnusedVariable = "information";
                };
              };
            };
          };
        };

        # Go
        gopls = {
          settings = {
            gopls = {
              gofumpt = true;
              codelenses = {
                gc_details = false;
                generate = true;
                regenerate_cgo = true;
                run_govulncheck = true;
                test = true;
                tidy = true;
                upgrade_dependency = true;
                vendor = true;
              };
              hints = {
                assignVariableTypes = true;
                compositeLiteralFields = true;
                compositeLiteralTypes = true;
                constantValues = true;
                functionTypeParameters = true;
                parameterNames = true;
                rangeVariableTypes = true;
              };
              analyses = {
                fieldalignment = true;
                nilness = true;
                unusedparams = true;
                unusedwrite = true;
                useany = true;
              };
              usePlaceholders = true;
              completeUnimported = true;
              staticcheck = true;
              directoryFilters = [
                "-.git"
                "-.vscode"
                "-.idea"
                "-node_modules"
              ];
              semanticTokens = true;
            };
          };
        };

        # TypeScript — lspconfig defaults
        ts_ls = { };

        # HTML — lspconfig defaults
        html = { };

        # CSS — lspconfig defaults
        cssls = { };

        # JSON
        jsonls = {
          settings = {
            json = {
              validate = { enable = true; };
            };
          };
        };

        # YAML
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = true;
                url = "https://www.schemastore.org/api/json/catalog.json";
              };
              schemas = { };
              validate = true;
              format = { enable = true; };
            };
          };
        };

        # TOML — lspconfig defaults
        taplo = { };

        # Zig
        zls = {
          filetypes = [ "zig" "zir" ];
          root_markers = [
            "build.zig.zon"
            "build.zig"
            "zig-out"
            "compile_commands.json"
          ];
        };

        # Dockerfile — lspconfig defaults
        dockerls = { };

        # docker-compose files — lspconfig defaults
        docker_compose_language_service = { };

        # Terraform / Terraform vars
        terraformls = {
          filetypes = [
            "terraform"
            "terraform-vars"
            "hcl"
          ];
        };
      };
    };

    luaConfigRC.lsp_config = ''
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "\u{25CF}",
        },
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = true,
          header = "",
          prefix = "",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "\u{F057} ",
            [vim.diagnostic.severity.WARN] = "\u{F071} ",
            [vim.diagnostic.severity.HINT] = "\u{F0335} ",
            [vim.diagnostic.severity.INFO] = "\u{F06A} ",
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local bufnr = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then
            return
          end

          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", vim.lsp.buf.references, "Go to references")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("<leader>D", vim.lsp.buf.type_definition, "Type definition")
          map("<leader>li", vim.lsp.buf.incoming_calls, "Incoming calls")
          map("<leader>lo", vim.lsp.buf.outgoing_calls, "Outgoing calls")

          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<C-S-k>", vim.lsp.buf.signature_help, "Signature help", { "n", "i" })

          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")

          map("<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
          map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
          map("[e", function() vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR }) end, "Previous error")
          map("]e", function() vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR }) end, "Next error")

          map("<leader>lwa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
          map("<leader>lwr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
          map("<leader>lwl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "List workspace folders")

          if client:supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
            end, "Toggle inlay hints")
          end

          if client:supports_method("textDocument/codeLens", { bufnr = bufnr }) then
            map("<leader>ll", vim.lsp.codelens.run, "Run codelens")
            map("<leader>lL", vim.lsp.codelens.refresh, "Refresh codelens")
          end

          if client:supports_method("textDocument/documentHighlight", { bufnr = bufnr }) then
            local group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
            vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = group,
              buffer = bufnr,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
              group = group,
              buffer = bufnr,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    '';

    keymaps = [
      {
        key = "<leader>xx";
        mode = "n";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        desc = "Diagnostics (Trouble)";
      }
      {
        key = "<leader>xX";
        mode = "n";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        desc = "Buffer diagnostics (Trouble)";
      }
      {
        key = "<leader>xs";
        mode = "n";
        action = "<cmd>Trouble symbols toggle focus=false<cr>";
        desc = "Symbols (Trouble)";
      }
      {
        key = "<leader>xl";
        mode = "n";
        action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>";
        desc = "LSP references (Trouble)";
      }
      {
        key = "<leader>xL";
        mode = "n";
        action = "<cmd>Trouble loclist toggle<cr>";
        desc = "Location list (Trouble)";
      }
      {
        key = "<leader>xQ";
        mode = "n";
        action = "<cmd>Trouble qflist toggle<cr>";
        desc = "Quickfix list (Trouble)";
      }
    ];
  };
}
