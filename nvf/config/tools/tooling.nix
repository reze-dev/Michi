{ pkgs, ... }: {
  config.vim = {
    # Declarative external developer tools via Nix
    # Eliminates any dependency on Mason / mason-tool-installer
    extraPackages = with pkgs; [
      # Language Servers (LSP)
      clang-tools # clangd, clang-format, clang-tidy
      rust-analyzer # rust-analyzer
      gopls # gopls
      basedpyright # basedpyright
      lua-language-server # lua-language-server
      nil # nil (Nix LSP)
      marksman # marksman (Markdown LSP)
      bash-language-server # bash-language-server
      dockerfile-language-server # dockerfile-language-server
      vscode-langservers-extracted # html, cssls, jsonls
      yaml-language-server # yaml-language-server
      taplo # taplo (TOML LSP & formatter)
      sqls # sqls (SQL LSP)
      superhtml # superhtml

      # Formatters
      rustfmt # rustfmt
      gotools # goimports
      gofumpt # gofumpt
      stylua # stylua
      ruff # ruff format / ruff linter
      prettier # prettier
      nixfmt # nixfmt (Nix RFC style)
      shfmt # shfmt
      gersemi # gersemi (CMake formatter)
      sqlfluff # sqlfluff (SQL formatter/linter)
      fish # fish_indent

      # Linters
      golangci-lint # golangci-lint

      # Debuggers & DAP Adapters
      vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb
      lldb # lldb, lldb-dap
      delve # dlv
      python3Packages.debugpy # debugpy

      # Go Ecosystem Tooling
      go # go compiler & toolchain
      gomodifytags # gomodifytags
      impl # impl
      iferr # iferr
      gotests # gotests

      # Rust Ecosystem Tooling
      cargo # cargo

      # Search & CLI Utilities
      ripgrep # rg (drives the Snacks picker grep sources)
      fd # fd (used by Telescope previously; kept for fzf habits)

      # Runtime deps the config calls directly
      # lazygit: visuals.nix binds <leader>gg and <leader>gl to
      #   Snacks.lazygit() / Snacks.lazygit.log(), which shell out to it.
      lazygit
      # graphviz: rust-analyzer draws inheritance/type MROs on "goto type
      # definition" and renders nothing without it.
      graphviz

      # NOT here, to avoid duplicating what home-manager already puts on PATH:
      #   fzf    -> modules/fish.nix programs.fzf
      #   bat    -> modules/fish.nix programs.bat
      #   zoxide -> modules/fish.nix programs.zoxide (a shell tool, not an
      #             editor dependency)
      # fd and ripgrep appear in both places; the nvf copies guarantee them
      # for :! and DAP launches even with a non-HM editor.
    ];

    # Enable native DAP presets
    debugger.nvim-dap.presets = {
      codelldb.enable = true;
      debugpy.enable = true;
    };
  };
}
