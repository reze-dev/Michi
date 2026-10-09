{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/neovim.nix
    ../../modules/graphics.nix
  ];

  networking.hostName = "Makima";
}
