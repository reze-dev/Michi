{ inputs, config, ... }:
{
  flake.nixosModules.neovim = {
    imports = [
      inputs.nvf.nixosModules.default
    ];

    programs.nvf = {
      enable = true;
      defaultEditor = true;

      settings = {
        imports = builtins.attrValues config.michi.nvfModules;
      };
    };
  };
}
