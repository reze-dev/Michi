{ inputs, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.sddm-pixel-theme = pkgs.stdenvNoCC.mkDerivation {
        pname = "sddm-pixel-theme";
        version = "unstable";
        src = inputs.sddm-pixel;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/share/sddm/themes/pixel
          cp -r * $out/share/sddm/themes/pixel/
        '';
      };
    };

  flake.nixosModules.desktop =
    { pkgs, ... }:
    let
      pixelTheme = self.packages.${pkgs.stdenv.hostPlatform.system}.sddm-pixel-theme;
    in
    {
      # ─── Display manager ─────────────────────────────────────────────────────
      # Niri is the only session, so the greeter has nothing to choose between.
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "pixel";
        extraPackages = [
          pkgs.kdePackages.qt5compat
        ];
      };

      environment.systemPackages = with pkgs; [
        pixelTheme
        # kitty and tmux are intentionally absent: kitty is owned by
        # programs.kitty in kitty.nix, and tmux by home.packages in base.nix.
        fuzzel
        wl-clipboard
        brightnessctl
        playerctl
        pactl
        grim
        satty
        # Media player. `playerctl` above is what exposes MPRIS metadata to
        # keybinders and status bars; mpv itself is the player.
        mpv
        # Image viewer (GNOME's Loupe) and document viewer (GNOME Papers).
        loupe
        papers
        # Cursor theme. Deliberately a systemPackage rather than a fonts.packages
        # entry: fonts.packages only feeds fontconfig <dir> entries, but cursor
        # lookup walks XDG_DATA_DIRS/icons. As a systemPackage this lands in
        # sw/share/icons/Bibata-Modern-Ice, where niri and every Xcursor client
        # can actually find it.
        bibata-cursors
        # Wallpaper engine. The client binary is what the island shells out
        # to when a wallpaper is applied; the daemon itself is started as a
        # user service by the island's module, in the `isle` namespace.
        awww
        # Helium is not in nixpkgs yet, so it comes from the tomsch/helium-nix
        # input (see flake.nix) rather than from pkgs.
        inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
