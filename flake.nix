{
  description = "reze's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.Makima = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/Makima
        ];
      };
    };
}
