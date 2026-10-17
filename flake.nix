{
  description = "reze's NixOS configuration";

  inputs = {
    # Host package set: flows with nixos-unstable. Everything in this repo
    # (kernel, mesa via hardware.graphics, devtools, nvf, fonts) builds from
    # this input, so it moves at unstable's pace. `nix flake update` is safe
    # here now that Ryoku is gone.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Era-matched to nixpkgs (nvf master needs pnpm_12, which is not in this rev).
    nvf.url = "github:notashelf/nvf/45ad22485d23";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    # Helium is not in nixpkgs yet (the PR adding it as a chromium variant has
    # not landed). This is an unofficial package, but it tracks upstream
    # releases closely, so it is tracked unlocked rather than pinned.
    helium.url = "github:tomsch/helium-nix";
    # Home Manager, used as a NixOS module (home-manager.nixosModules.default)
    # rather than a standalone generation, so it activates with nixos-rebuild.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, nvf, helium, home-manager }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.Makima = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit helium; };
        modules = [
          nvf.nixosModules.default
          home-manager.nixosModules.default
          ./hosts/Makima
        ];
      };
    };
}
