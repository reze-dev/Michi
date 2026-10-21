{
  description = "reze's NixOS configuration";

  inputs = {
    # Host package set: flows with nixos-unstable. Everything in this repo
    # (kernel, mesa via hardware.graphics, devtools, nvf, fonts) builds from
    # this input, so it moves at unstable's pace. `nix flake update` is safe
    # here now that Ryoku is gone.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Dendritic pattern foundation: flake-parts + automatic recursive file loader.
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Era-matched to nixpkgs (nvf master needs pnpm_12, which is not in this rev).
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    # Helium is not in nixpkgs yet (the PR adding it as a chromium variant has
    # not landed). This is an unofficial package, but it tracks upstream
    # releases closely, so it is tracked unlocked rather than pinned.
    helium.url = "github:tomsch/helium-nix";

    # Home Manager, used as a NixOS module (home-manager.nixosModules.default)
    # rather than a standalone generation, so it activates with nixos-rebuild.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # The Dynamic Island Shell: the island, its daemon, and the keybinds.
    # A separate project with its own release cycle, so it is tracked as an
    # input rather than vendored in.
    isle.url = "github:reze-dev/dynamic-island";

    # SDDM theme (pixel branch)
    sddm-pixel = {
      url = "github:mahaveergurjar/sddm/pixel";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      # Automatically imports every .nix file under ./modules as a flake-parts module
      imports = [
        (import-tree ./modules)
      ];
    };
}
