{
  config,
  pkgs,
  ...
}:

{
  # Battery-low notification (the original ~/.config/systemd/user unit).
  systemd.user.services.battery-notify = {
    Unit = {
      Description = "Battery low notification at 15%";
      After = [ "dunst.service" ];
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/.local/bin/battery-notify";
      Restart = "always";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Re-apply `xset s off -dpms` every minute. i3 does this on startup, but some
  # applications reset the X screensaver/DPMS state.
  #
  # /usr/bin/xset and the old Ly Xauthority path are replaced with store paths
  # and the standard ~/.Xauthority.
  systemd.user.services.keep-awake-display = {
    Unit = {
      Description = "Disable X screen blanking and DPMS (re-applied periodically)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.xorg.xset}/bin/xset s off -dpms";
      # DISPLAY and XAUTHORITY are imported into the systemd user manager by
      # the NixOS i3 session (updateSessionEnvironment), so inherit them here
      # instead of hardcoding Ly's private xauth path.
      Nice = 19;
    };
  };

  systemd.user.timers.keep-awake-display = {
    Unit.Description = "Periodically keep the X display from blanking or powering off";
    Timer = {
      OnStartupSec = "15s";
      OnUnitActiveSec = "60s";
      AccuracySec = "1s";
      Persistent = false;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # The old prevent-sleep.service was only a static inhibitor. sleep-toggle
  # (Mod+C) provides the same thing on demand, so it is not enabled here.
  # Uncomment to keep the machine awake permanently:
  #
  # systemd.user.services.prevent-sleep = {
  #   Unit.Description = "Prevent idle/suspend/lid-close sleep";
  #   Service = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=idle:sleep:handle-lid-switch --who=prevent-sleep --why='User requested the PC stay awake' --mode=block ${pkgs.coreutils}/bin/sleep infinity";
  #     Restart = "no";
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };
}
