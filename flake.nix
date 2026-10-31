{
  description = "NixOS flake based upon dendritic patterns";

  inputs = {
    # Tracks nixos-unstable rolling release. Everything in this repo builds from this
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Dendritic pattern foundation: flake-parts + automatic recursive file loader.
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Era-matched to nixpkgs (nvf master needs pnpm_12, which is not in this rev).
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Helium is not in nixpkgs this flake provides helium browser
    helium.url = "github:tomsch/helium-nix";

    # Home Manager, used as a NixOS module rather than a standalone generation.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The serpantinum shell a quickshell layer for wayland compositors and supports niri.
    serpantinum.url = "github:ilyamiro/serpantinum";

    # Secrets are encrypted in ./secrets and decrypted by the Home Manager
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix index database url
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SDDM theme (pixel branch)
    sddm-pixel = {
      url = "github:mahaveergurjar/sddm/pixel";
      flake = false;
    };
  };

  outputs =
    inputs@{
      flake-parts,
      import-tree,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      # Automatically imports every .nix file under ./modules as a flake-parts module
      imports = [
        (import-tree ./modules)
      ];
    };
}
