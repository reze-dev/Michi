# Home-manager config for reze. Imported as a NixOS module from base.nix via
# `home-manager.users.reze`, so it is activated by nixos-rebuild.
#
# This file is the aggregator only — each concern lives in its own module
# alongside the others in modules/.

{ pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./kitty.nix
    ./niri.nix
  ];

  home.stateVersion = "26.11";

# User packages with no home-manager module of their own.
home.packages = with pkgs; [
    # For the `tmux -u` alias in fish.nix.
    tmux

    # Lightweight GUI editor for quick edits — nix config, JSON, /etc files.
    # Deliberately not Emacs or gedit: this is 4 MiB against Emacs's 671 MiB,
    # and nvim (via nvf) remains the real editor. Bound to Mod+A in niri.nix.
    gnome-text-editor
  ];
}