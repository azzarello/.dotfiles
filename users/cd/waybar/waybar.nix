{ config, pkgs, ... }:
let
  waybar = (pkgs.waybar.override { pulseSupport = true; });
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 24;
        output = [
          "eDP-1"
        ];
        spacing = 5;
        modules-left = [ "sway/workspaces" "sway/window" ];
        modules-center = [ ];
        modules-right = [ "mpd" "idle_inhibitor" "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock" "tray" ];
        "battery" = {
          bat = "BAT0";
          states = {
            # good = 95;
            warning  = 30;
            critical = 15;
          };
          format = "{icon} {capacity}% {time} {power}";
          format-time = "{H}:{M}";
          # format-good = ""; # An empty format will hide the module
          # format-full = "";
          format-icons = ["" "" "" "" ""];
          interval = 1;
        };
        "clock" = {
          timezone = "America/Los_Angeles";
          interval = 1;
          format = "{:%I:%M}";
        };
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
              "activated" = "";
              "deactivated" = "";
          };
        };
        "network" = {
          format = "{essid} {signalStrength}% UP {bandwidthUpBytes} DOWN {bandwidthDownBytes}";
          interval = 1;
        };
        "tray" = {
          spacing = "50";
        };
        "cpu" = {
          format = "{usage}% ";
          on-click = "${pkgs.foot}/bin/foot start ${pkgs.btop}/bin/btop";
          tooltip = true;
          interval = 1;
        };
        "memory" = { format = "{used}GB "; };
        "temperature" = {
          critical-threshold = 80;
          format = "{temperatureC}°C";
          format-icons = [ "" "" "" ];
        };
        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-icons = {
            car = "";
            default = [ "" "" "" ];
            handsfree = "";
            headphones = "";
            headset = "";
            phone = "";
            portable = "";
          };
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };
      };
    };
    systemd.enable = false;
  };

  xdg.configFile."${config.xdg.configHome}/waybar/style.css".source = ./style.css;
  
  systemd.user.services.waybar = {
    Unit = {
      Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "dbus";
      BusName = "fr.arouillard.waybar";
      ExecStart = "${waybar}/bin/waybar"; # FIXME see above
      Restart = "always";
      RestartSec = "1sec";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
