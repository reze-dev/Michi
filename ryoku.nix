# Managed by ryoku-install.
{ config, lib, pkgs, ... }:

{
  programs.ryoku = {
    enable = true;
    defaultCompositor = "niri";
    browser = "firefox";
    shell = "fish";
    optionalApps = [
      "prompt"
      "bash-edit"
      "fastfetch"
      "yazi"
      "cli-tools"
      "git-tools"
      "pavucontrol"
      "songrec"
      "openrgb"
      "upscale"
      "localsend"
      "gamescope"
      "gamemode"
      "mangohud"
      "vm"
      "docker"
      "flatpak"
      "go"
      "pytools"
      "mise"
    ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.initrd.kernelModules = lib.mkAfter [ "amdgpu" ];

  # NVIDIA detected by ryoku-install: 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU117M [GeForce GTX 1650 Ti Mobile] [10de:1f95] (rev a1)
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
