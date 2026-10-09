{ ... }:

{
  # Hybrid graphics: the internal panel (eDP-1) is wired to the amdgpu iGPU
  # (card1); the NVIDIA dGPU (card0) has no connected outputs. Compositors must
  # render on the iGPU, otherwise the mixed atomic commit hard-freezes the
  # machine. niri is additionally pinned via render-drm-device in its user.kdl.
  environment.sessionVariables = {
    AQ_DRM_DEVICES = "/dev/dri/card1"; # hyprland / aquamarine
    WLR_DRM_DEVICES = "/dev/dri/card1"; # wlroots compositors
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    LIBVA_DRIVER_NAME = "radeonsi";
  };
}
