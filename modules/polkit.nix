# Polkit: the authorization daemon, plus a GNOME agent so its prompts appear.
{ pkgs, ... }:

{
  # Already enabled transitively — udisks2 (pulled in by services.gvfs) turns
  # this on. Stated explicitly because the agent below is inert without it.
  security.polkit.enable = true;

  # No authorization rules are declared here. udisks2 ships its own polkit
  # policy allowing an active local session to mount removable drives, which
  # covers the USB/MTP case in storage.nix. Add rules under
  # `security.polkit.rules` if something else needs them.
  #
  # NixOS deliberately has no option to run a polkit *agent* — its polkit
  # module only wires up polkit-agent-helper@, which is a different thing.
  # Without an agent, anything needing authorization (mounting a USB drive,
  # NetworkManager, package management) shows no dialog and just fails.
  #
  # polkit_gnome is the GNOME authentication agent, renamed from
  # gnome-shell-polkit in nixpkgs; it ships no systemd unit of its own.
  systemd.user.services.polkit-gnome-authentication-agent = {
    description = "GNOME authentication agent for polkit";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}