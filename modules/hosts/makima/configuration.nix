{ inputs, self, ... }:
{
  flake.nixosModules.makima = {
    networking.hostName = "Makima";
  };

  flake.nixosConfigurations.Makima = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = builtins.attrValues self.nixosModules;
  };
}
