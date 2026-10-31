{ inputs, ... }:
{
  flake.nixosModules.serpantinum = {
    imports = [
      inputs.serpantinum.nixosModules.default
    ];
    programs.serpantinum.enable = true;
  };

  flake.homeModules.serpantinum = {
    imports = [
      inputs.serpantinum.homeManagerModules.default
    ];
    programs.serpantinum = {
      enable = true;
      systemd.enable = true;

      settings = {
        general = {
          language = "en";
          weatherUnit = "metric";
          weatherInterval = 30;
        };

        theme = {
          fontFamily = "Maple Mono";
          borderRadius = 12;
          matugen = true;
        };
      };
    };
  };
}
