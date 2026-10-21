{ ... }:
{
  flake.nixosModules.graphics =
    { config, lib, ... }:

    # Hybrid graphics: AMD iGPU (card1) drives the internal panel, NVIDIA RTX
    # 1650 Ti (card0) is the dGPU. Compositors must render on the iGPU — a mixed
    # atomic commit across the two GPUs hard-freezes the machine.
    #
    # The NVIDIA half came from the old ryoku.nix; it is plain NixOS and survives
    # Ryoku's removal unchanged.
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      boot.initrd.kernelModules = lib.mkAfter [ "amdgpu" ];

      # No services.xserver.videoDrivers here: services.xserver is off (Wayland
      # only), so nothing reads that list. Xwayland picks up the NVIDIA userspace
      # bits from hardware.nvidia on its own.

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        # The RTX 1650 Ti is Turing. NVIDIA stopped shipping the proprietary kernel
        # module flavor for Turing-and-newer at driver 590, so open is the only
        # flavor this card can actually use on `latest`.
        open = true;
        nvidiaSettings = true;
        # `latest` is whichever is newer of `production` and `new_feature` — 615.78.08
        # (New Feature Branch) as of this nixpkgs rev, vs 595.104.02 for `stable`.
        # `nvidiaPackages.latest` rather than a pinned branch so `nix flake update`
        # carries it forward instead of leaving it stuck on an old driver.
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };

      # Pinned for the compositors so they never pick the dGPU as the renderer.
      # Niri reads WLR_DRM_DEVICES from its own generated config, which is what
      # actually decides the render device — this is the fallback for everything else.
      environment.sessionVariables = {
        WLR_DRM_DEVICES = "/dev/dri/card1"; # wlroots compositors (niri)
        __GLX_VENDOR_LIBRARY_NAME = "mesa";
        LIBVA_DRIVER_NAME = "radeonsi";
      };
    };
}
