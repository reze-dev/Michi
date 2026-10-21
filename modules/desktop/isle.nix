{ inputs, self, ... }:
{
  # ─── The Dynamic Island Shell ───────────────────────────────────────────────
  # The island, its daemon, and the wallpaper engine that goes with it. The
  # Home Manager module lives in the island's own flake, because the island
  # is a separate project with its own release cycle; this module is only
  # the wiring.
  flake.homeModules.isle = { pkgs, lib, ... }: {
    imports = [ inputs.isle.homeModules.default ];

    programs.isle = {
      enable = true;

      # The session bus name is free: the shell that used to own it is gone.
      # isled asks for it without queueing, so if anything else has taken it
      # in the meantime it logs that it did not get it rather than stealing
      # it. Check `features.notifications` in the snapshot to see which
      # happened.
      claimNotifications = true;

      # One target, and it has to name a compositor that is actually
      # installed: a unit whose WantedBy names a target that does not exist
      # is never started at all.
      sessionTargets = [ "niri-session.target" ];
    };
  };
}
