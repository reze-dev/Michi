{ pkgs, helium, ... }:

{
  # ─── Display manager ─────────────────────────────────────────────────────
  # Niri is the only session, so the greeter has nothing to choose between.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };

  # ─── Compositor ───────────────────────────────────────────────────────────
  # System-level half only: this registers the niri session with the display
  # manager and sets up xdg-desktop-portal (including the gnome/gtk FileChooser
  # and the keyring Secret portal).
  #
  # The user's config.kdl is NOT here — that is home-manager's job, in
  # modules/home.nix via wayland.windowManager.niri.
  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  environment.systemPackages = with pkgs; [
    # kitty and tmux are intentionally absent: kitty is owned by
    # programs.kitty in home.nix, and tmux by home.packages in home.nix.
    fuzzel
    mako
    nautilus
    wl-clipboard
    brightnessctl
    playerctl
    # Media player. `playerctl` above is what exposes MPRIS metadata to
    # keybinders and status bars; mpv itself is the player.
    mpv
    # Wallpaper daemon. Started from niri's spawn-at-startup (modules/home.nix);
    # by default it restores the last wallpaper from its cache on start.
    awww
    # Helium is not in nixpkgs yet, so it comes from the tomsch/helium-nix
    # input (see flake.nix) rather than from pkgs.
    helium.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
