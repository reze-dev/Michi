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

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Pinned for the compositors so they never pick the dGPU as the renderer.
  # Hyprland (AQ_DRM_DEVICES) and Niri (WLR_DRM_DEVICES) also read these from
  # their own generated configs, which is what actually decides the render
  # device — these are the fallback for everything else.
  environment.sessionVariables = {
    AQ_DRM_DEVICES = "/dev/dri/card1"; # hyprland / aquamarine
    WLR_DRM_DEVICES = "/dev/dri/card1"; # wlroots compositors
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    LIBVA_DRIVER_NAME = "radeonsi";
  };
}
