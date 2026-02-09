{
  self,
  goather,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.myQuickshell;

  defaultGoatherPackage =
    let
      packageFromPackages = lib.attrByPath ["packages" pkgs.system "default"] null goather;
      packageFromDefaultPackage = lib.attrByPath ["defaultPackage" pkgs.system] null goather;
      package = if packageFromPackages != null then packageFromPackages else packageFromDefaultPackage;
    in
      if package == null
      then throw "goather flake does not expose packages.${pkgs.system}.default or defaultPackage.${pkgs.system}"
      else package;

  runtimePackages =
    [
      pkgs.quickshell
      pkgs.wireplumber
      pkgs.pulseaudio
      pkgs.brightnessctl
      pkgs.power-profiles-daemon
      pkgs.pavucontrol
    ]
    ++ lib.optionals (cfg.workspaceBackend == "niri") [pkgs.niri]
    ++ lib.optionals cfg.enableGoather [cfg.goatherPackage]
    ++ lib.optionals cfg.startNmApplet [pkgs.networkmanagerapplet]
    ++ lib.optionals cfg.startBluemanApplet [pkgs.blueman]
    ++ cfg.extraPackages;
in {
  options.programs.myQuickshell = {
    enable = lib.mkEnableOption "my Quickshell config";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.default;
      description = "Package containing the Quickshell source tree.";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start my Quickshell automatically in graphical sessions.";
    };

    startNmApplet = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start nm-applet from this Quickshell setup.";
    };

    startBluemanApplet = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start blueman-applet from this Quickshell setup.";
    };

    workspaceBackend = lib.mkOption {
      type = lib.types.enum ["hyprland" "niri"];
      default = "hyprland";
      description = "Workspace backend used by the workspace widget.";
    };

    enableGoather = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable goather in the Quickshell runtime PATH.";
    };

    goatherPackage = lib.mkOption {
      type = lib.types.package;
      default = defaultGoatherPackage;
      description = "goather package used by the weather widget.";
    };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [];
      description = "Additional runtime packages added to PATH for Quickshell.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = runtimePackages;

    systemd.user.services.import-session-env = {
      Unit = {
        Description = "Import session environment into systemd user manager";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS";
        ExecStartPost = "${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS";
        RemainAfterExit = true;
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    systemd.user.services.my-quickshell = {
      Unit = {
        Description = "my Quickshell";
        After = [
          "graphical-session.target"
          "import-session-env.service"
        ];
        Wants = ["import-session-env.service"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${pkgs.quickshell}/bin/qs --path ${cfg.package}/share/my-quickshell/src/shell.qml";
        Restart = "on-failure";
        RestartSec = 1;
        Environment = [
          "PATH=${lib.makeBinPath runtimePackages}"
          "MYQS_START_NM_APPLET=${if cfg.startNmApplet then "1" else "0"}"
          "MYQS_START_BLUEMAN_APPLET=${if cfg.startBluemanApplet then "1" else "0"}"
          "MYQS_WORKSPACE_BACKEND=${cfg.workspaceBackend}"
          "QT_QPA_PLATFORM=wayland"
        ];
      };

      Install = lib.mkIf cfg.autoStart {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
