{
  description = "reze's NixOS configuration";

  inputs = {
    # Pinned to Ryoku's ryokuPackagesNixpkgs rev on purpose: ryoku builds its
    # packages (and their glibc/mesa) from that fixed input. Any other nixpkgs
    # rev means two glibcs in one system closure — a mesa built on a newer
    # glibc fails with 'GLIBC_2.43 not found' against Ryoku's libm and every
    # Wayland compositor freezes. Update both together (see docs/nixos.md).
    nixpkgs.url = "github:NixOS/nixpkgs/56c02bc00adcf003215cc4bd996d6efaf4cff188";
    ryoku = {
      url = "github:aethctl/Ryoku-on-NixOS/main";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { ryoku, self, nixpkgs, nvf }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.Makima = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ryoku.nixosModules.default
          ./ryoku.nix
          nvf.nixosModules.default
          ./hosts/Makima
        ];
      };
    };
}
