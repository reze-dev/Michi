{ ... }:
{
  michi.nvfModules.tooling = { pkgs, ... }: {
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
        typescript-language-server # tsserver
        vscode-langservers-extracted # html, cssls, jsonls
        yaml-language-server # yamlls
        dockerfile-language-server # dockerls
        docker-compose-language-service # docker_compose_language_service
        terraform-ls # terraformls
        taplo # taplo (TOML LSP & formatter)
        zls # zls
        nil # nil (Nix LSP)

        # Formatters
        rustfmt # rustfmt
        gotools # goimports
        gofumpt # gofumpt
        stylua # stylua
        ruff # ruff format / ruff linter
        prettier # prettier
        nixfmt # nixfmt (Nix RFC style)
        shfmt # shfmt
        fish # fish_indent

        # Linters
        golangci-lint # golangci-lint
        yamllint # yamllint
        hadolint # hadolint
        tflint # tflint
        terraform # terraform fmt

        # Debuggers & DAP Adapters
        vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb
        delve # dlv

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
        fd # fd

        # Runtime deps the config calls directly
        # lazygit: visuals.nix binds <leader>gg and <leader>gl to
        #   Snacks.lazygit() / Snacks.lazygit.log(), which shell out to it.
        lazygit
        # graphviz: rust-analyzer draws inheritance/type MROs on "goto type
        # definition" and renders nothing without it.
        graphviz
      ];
    };
  };
}
