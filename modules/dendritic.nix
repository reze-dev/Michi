{ lib, ... }:
let
  mkModuleAttrOption =
    description:
    lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = { };
      inherit description;
    };
in
{
  options.flake = {
    homeModules = mkModuleAttrOption "Dendritic Home Manager modules";
  };

  options.michi = {
    nvfModules = mkModuleAttrOption "Dendritic nvf Neovim modules";
  };
}
