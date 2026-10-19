{ lib, ... }:
let
  mkModuleAttrOption = description:
    lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = { };
      inherit description;
    };
in
{
  options.flake = {
    nixosModules = mkModuleAttrOption "Dendritic NixOS modules";
    homeModules = mkModuleAttrOption "Dendritic Home Manager modules";
    nvfModules = mkModuleAttrOption "Dendritic nvf Neovim modules";
  };
}
