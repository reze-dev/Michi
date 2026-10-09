{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/neovim.nix
  ];

  networking.hostName = "Makima";
}
