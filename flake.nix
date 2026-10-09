{
  description = "reze's NixOS configuration";

  inputs = {
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
