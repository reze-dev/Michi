# Home-manager config for reze. Imported as a NixOS module from base.nix via
# `home-manager.users.reze`, so it is activated by nixos-rebuild.
#
# This file is the aggregator only — each concern lives in its own module
# alongside the others in modules/.

{
  imports = [ ./niri.nix ];

  home.stateVersion = "26.11";
}