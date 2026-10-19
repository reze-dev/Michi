{ inputs, ... }:
{
  flake.nixosModules.desktop = { pkgs, ... }: {
    # ─── Display manager ─────────────────────────────────────────────────────
    # Niri is the only session, so the greeter has nothing to choose between.
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "breeze";
    };

    environment.systemPackages = with pkgs; [
      # kitty and tmux are intentionally absent: kitty is owned by
      # programs.kitty in kitty.nix, and tmux by home.packages in base.nix.
      fuzzel
      mako
      nautilus
      wl-clipboard
      brightnessctl
      playerctl
      # Media player. `playerctl` above is what exposes MPRIS metadata to
      # keybinders and status bars; mpv itself is the player.
      mpv
      # Cursor theme. Deliberately a systemPackage rather than a fonts.packages
      # entry: fonts.packages only feeds fontconfig <dir> entries, but cursor
      # lookup walks XDG_DATA_DIRS/icons. As a systemPackage this lands in
      # sw/share/icons/Bibata-Modern-Ice, where niri and every Xcursor client
      # can actually find it.
      bibata-cursors
      # Wallpaper daemon. Started from niri's spawn-at-startup (niri.nix);
      # by default it restores the last wallpaper from its cache on start.
      awww
      # Helium is not in nixpkgs yet, so it comes from the tomsch/helium-nix
      # input (see flake.nix) rather than from pkgs.
      inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
