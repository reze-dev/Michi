{ inputs, ... }:
{
  flake.nixosModules.serpantinum = {
    modules = [
      inputs.serpantinum.nixosModules.default
    ];
    programs.serpantinum.enable = true;
  };

  flake.homeModules.serpantinum = {
    programs.serpantinum = {
      systemd.enable = true;
    };

    settings = {
      general = {
        language = "en";
        weatherUnit = "metric";
        weatherInterval = 30;
      };
    };

    theme = {
      fontFamily = "Maple Mono";
      borderRadius = 12;
      matugen = true;
    };
  };
}
