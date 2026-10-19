{ ... }:
{
  flake.nixosModules.devtools = { pkgs, ... }:

# Development toolchains. Grouped by language/runtime so a future removal is a
# one-line delete, and every entry is a plain environment.systemPackages item
# (nothing here sets up a devShell; direnv/nix-direnv handle per-project env).

{
  environment.systemPackages = with pkgs; [
    # -- languages & toolchains ------------------------------------------------
    go_latest          # go
    rustup             # rustc/cargo via rustup toolchains
    python3            # python
    uv
    ruff
    zig
    metals             # scala LSP
    zls                # zig LSP
    gcc
    libgcc
    clang
    clang-tools        # clangd, clang-tidy
    nodejs
    bun
    tuios                # terminal window manager

    # -- build & task runners -------------------------------------------------
    just
    xmake

    # -- data -----------------------------------------------------------------
    duckdb

    # -- jvm ------------------------------------------------------------------
    coursier
    jdk21

    # -- editors / ides (unfree: allowUnfree is enabled in base.nix) ----------
    jetbrains.idea
  ];
}
;
}
