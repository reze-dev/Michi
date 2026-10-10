{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/neovim.nix
    ../../modules/graphics.nix
    ../../modules/devtools.nix
  ];

  networking.hostName = "Makima";
}
