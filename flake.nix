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
  };

  outputs =
    { self, nixpkgs, nvf }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.Makima = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nvf.nixosModules.default
          ./hosts/Makima
        ];
      };
    };
}
