{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/neovim.nix
    ../../modules/graphics.nix
    ../../modules/devtools.nix
    ../../modules/storage.nix
  ];

  networking.hostName = "Makima";
}
