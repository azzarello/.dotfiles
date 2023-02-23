{ config, pkgs, lib, ... }:
let
  swayGreetdConfig = pkgs.writeText "greetd-sway-config" ''
  # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
  exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c sway; swaymsg exit"
  bindsym Mod4+shift+e exec swaynag \
    -t warning \
    -m 'What do you want to do?' \
    -b 'Poweroff' 'systemctl poweroff' \
    -b 'Reboot' 'systemctl reboot'
  '';
  idleCmd = ''swayidle -w \
   timeout 90 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"'
  '';
  theme = import ./theme.nix { inherit pkgs; };
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };
  systemdRun = { pkg, bin ? pkg.pname, args ? "" }: ''
    systemd-run --user --scope --collect --quiet --unit=${bin} \
    systemd-cat --identifier=${bin} ${lib.makeBinPath [ pkg ]}/${bin} ${args}
  '';
  wmMod = "Mod4";
in
{
  imports = [
    ./waybar/waybar.nix
    ./neovim.nix
  ];

  xdg = {
    enable = true;
    # configHome = "${config.environment.variables.XDG_CONFIG_HOME}";
  };
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };

  home.stateVersion = "18.09";
  home.packages = with pkgs; [
    foot
    swaybg
    # rapid-photo-downloader
    cheat
    mpd
    mako
    wl-clipboard
    obs-studio
    pulseaudio
    pavucontrol
    btop
    pipes-rs
    gparted
    btrfs-progs
    jq
    ripgrep
    zoxide
    exa
    ncdu
    ranger
    fd
    gitui
    openssl
    rclone
    hyperfine
    nix-du
    zgrviewer
    graphviz
    nodejs
    cargo
    unzip
    gcc
    tmux
    rustc
    fira-code
    fira-code-symbols
    tealdeer
    qutebrowser
    luakit
    starship
    ytfzf
    vaultwarden
    bitwarden
    bitwarden-cli
    bitwarden-menu
    spotify
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    dconf
    dbus-sway-environment
    light
    firefox
    git
    nixpkgs-fmt
    discord
    element-desktop
    signal-desktop
    slack
    teams
    ferdium
    zoom-us
    noisetorch
    waybar
    nix-output-monitor
    nerdfonts
    bat
    deluge
    mpv
    direnv
    gammastep
    swaylock
    swayidle
    zsh-autopair
    zsh-autosuggestions
    zsh-completions
    # zsh-defer
    zsh-fast-syntax-highlighting
    zsh-you-should-use
    steam
    steam-tui
    protonup
    mangohud
    goverlay
    vkbasalt
    gamescope
    gamemode
    wally-cli
    lutris
  ];
  wayland.windowManager.sway = {
    enable = true;
    # extraConfigEarly = swayGreetdConfig;
    config = rec {
      bars = [];
      /* bars = [{
        mode = "hide";
        hiddenState = "hide";
        trayOutput = "*";
        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 10.0;
        };
        position = "bottom";
      }]; */
      gaps = {
        smartBorders = "on";
      };
      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
      };
      modifier = wmMod;
      terminal = "foot";
      input = {
        # "*" = {
        #   xkb_options = "ctrl:nocaps";
        # };
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
        };
      };
      keybindings =
        lib.mkOptionDefault {
          "${wmMod}+q" = "kill";
          # "${wmMod}+b" = "exec ${systemdRun { pkg = pkgs.firefox; bin = "firefox"; } }";
          "${wmMod}+b" = "exec firefox";
          "${wmMod}+e" = "exec ${systemdRun { pkg = pkgs.foot; bin = "foot"; args = "ranger"; } }";
          "${wmMod}+Alt+h" = "exec ${systemdRun { pkg = pkgs.foot; bin = "foot"; args = "btop"; } }";
          "${wmMod}+t" = "layout tabbed";
          "${wmMod}+w" = "layout toggle split";
          "${wmMod}+tab" = "workspace next";
          "${wmMod}+Shift+tab" = "workspace prev";
        };
      startup = [
        # { command = "firefox"; }
        { command = "swaybg -i pictures/wallpapers/nix-wallpaper-nineish-dark-gray.png -m fill &"; }
        { command = "${idleCmd}"; }
      ];
      assigns = {
        "9" = [
          { class = "Element"; }
        ];
      };
    };
    extraConfig = ''
      smart_gaps on
      gaps inner 5
      for_window [class="Spotify"] move window to workspace 8

      # Brightness
      bindsym XF86MonBrightnessDown exec light -U 10
      bindsym XF86MonBrightnessUp exec light -A 10

      # Volume
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +2%'
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -2%'
      bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'
      bindsym XF86AudioMicMute exec 'pactl set-source-mute @DEFAULT_SOURCE@ toggle'

      exec systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
      exec dbus-update-activation-environment WAYLAND_DISPLAY
      exec dbus-sway-environment
    '';
    wrapperFeatures.gtk = true;
    systemdIntegration = true;
  };
  programs = {
    bash = {
      enable = true;
      profileExtra = ''
      '';
      shellAliases = {
        l = "exa";
        la = "exa -a";
        ls = "exa -la";
        ll = "exa -l";
        ".." = "cd ..";
        rebuild = ''
          export DATE=backup-$(date +%d%m%y%H%M%S)
          sudo nixos-rebuild switch -I ./.dotfiles/system/configuration.nix --upgrade-all |& nom \
          home-manager switch -f ./.dotfiles/users/cd/home.nix -b $DATE |& nom
        '';
      };
    };
    git = {
      enable = true;
      userName = "azzarello";
      userEmail = "connor.azzarello@gmail.com";
      aliases = {
        gs = "status";
      };
    };

    zsh = {
      enable = true;
      shellAliases = {
        l = "exa";
        la = "exa -a";
        ls = "exa -la";
        ll = "exa -l";
        ".." = "cd ..";
        whatismyip = "wget -qO- https://ipecho.net/plain ; echo";
        rebuild = ''
          export DATE=backup-$(date +%d%m%y%H%M%S) \
            sudo nixos-rebuild switch -I ./.dotfiles/system/configuration.nix --upgrade-all |& nom \
            home-manager switch -f ./.dotfiles/users/cd/home.nix -b $DATE |& nom
        '';
      };
      history = {
        size = 10000;
        # path = "${config.home.homeDirectory}/.zsh/history";
        ignoreSpace = true;
        expireDuplicatesFirst = true;
        extended = true;
        ignorePatterns = [
          "rm *"
          "pkill *"
        ];
        share = true;
      };
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autocd = true;
      defaultKeymap = "vicmd";
      dirHashes = {
        dl    = "$HOME/Downloads";
      };
      historySubstringSearch = {
        enable = true;
      };
      initExtra = ''
        bindkey -v
        export KEYTIMEOUT=1

        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'j' vi-down-line-or-history
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
      '';
    };

    # fish = {
    #   enable = true;
    #   shellAliases = {
    #     se = "sudo $EDITOR -u $XDG_CONFIG_HOME/nvim/init.lua";
    #     rebuild = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch && sudo nixos-rebuild switch --upgrade-all";
    #     rebuild-reboot = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch && sudo nixos-rebuild boot --upgrade-all && sudo reboot now";
    #     rebuild-shutdown = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch && sudo nixos-rebuild boot --upgrade-all && sudo shutdown now";
    #     rebuild-boot = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch && sudo nixos-rebuild boot --upgrade-all";
    #     hrc = "$EDITOR $HOME/nixfiles/home.nix";
    #     hcrc = "$EDITOR $HOME/nixfiles/config.nix";
    #     vrc = "$EDITOR $HOME/nixfiles/neovim.nix";
    #     gs = "git status";
    #     gp = "git push";
    #     k = "kubectl";
    #
    #   };
    #   shellInit = ''
    #     zoxide init fish | source
    #     set -x EDITOR nvim
    #     direnv hook fish | source
    #     set -g direnv_fish_mode eval_on_arrow
    #   '';
    # };

    starship = {
      enable = true;
      # enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    qutebrowser = {
      enable = true;
      loadAutoconfig = true; # For notification prompts
      searchEngines.DEFAULT = "https://duckduckgo.com/search?q={}";
      keyBindings = {
        normal = {
          "gk" = "scroll-to-perc 0";
          "gj" = "scroll-to-perc 100";
          "e" = "config-cycle statusbar.show always never";
          "E" = "config-cycle tabs.position right top";
          "z" = "spawn --userscript qute-bitwarden";
          "+" = "zoom-in";
          "-" = "zoom-out";
        };
        insert = {
          "<Ctrl-E>" = "open-editor";
        };
      };
      extraConfig = ''
        c.statusbar.padding = {
          "bottom": 8,
          "left": 2,
          "right": 2,
          "top": 8
        }
        c.tabs.padding = {
          "bottom": 8,
          "left": 5,
          "right": 5,
          "top": 8
        }
      '';
      settings = {
        auto_save.session = true;
        session.lazy_restore = true;
        qt.args = [ "ignore-gpu-blocklist" "enable-gpu-rasterization" "enable-accelerated-video-decode" "enable-features=WebRTCPipeWireCapturer" ];

        url.start_pages = "https://search.nixos.org/";

        completion.web_history.exclude = [
          "*://kagi.com/*"
          "*://duckduckgo.com/*"
          "*://www.google.com/*"
          "*://twitter.com/*"
          "*://twitch.com/videos/*"
          "*://discord.com/*"
          "*://piped.kavin.rocks/*"
          "*://*.youtube.com/*"
          "*://*.reddit.com/r/*"
        ];

        content.autoplay = false;
        content.blocking = {
          enabled = true;
          method = "adblock";
          adblock.lists = [
            "https://easylist.to/easylist/easylist.txt"
            "https://easylist.to/easylist/easyprivacy.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt"
            "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
            "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
            "https://hosts.netlify.app/Pro/adblock.txt"
            "https://filters.adtidy.org/extension/ublock/filters/2.txt"
          ];
        };

        tabs = {
          indicator.width = 0;
          title.format = "{audio}{current_title} {private}"; # {index}:
          background = true;
          show = "multiple";
          position = "top";
        };

        statusbar = {
          show = "never";
          position = "top";
        };

        downloads.position = "bottom";

        fonts.default_family = with theme.font; "${name}";

        colors = with theme.colors; {
          # Dark theme
          webpage = {
            preferred_color_scheme = "dark";
            darkmode.enabled = true;
            darkmode.policy.images = "never";
            bg = "${background}";
          };

          completion = {
            fg = "${foreground}";
            odd.bg = "${background}";
            even.bg = "${background}";
            category = {
              fg = "${blue}";
              bg = "${background}";
              border.top = "${background}";
              border.bottom = "${background}";
            };
            item.selected = {
              fg = "${foreground}";
              bg = "${darkGrey}";
              border.top = "${darkGrey}";
              border.bottom = "${darkGrey}";
              match.fg = "${lighterGrey}";
            };
            match.fg = "${orange}";
            scrollbar.fg = "${lighterGrey}";
            scrollbar.bg = "${background}";
          };

          contextmenu = {
            disabled.bg = "${darkerGrey}";
            disabled.fg = "${lightGrey}";
            menu.bg = "${background}";
            menu.fg = "${lighterGrey}";
            selected.bg = "${darkGrey}";
            selected.fg = "${lighterGrey}";
          };

          downloads = {
            bar.bg = "${background}";
            start.fg = "${background}";
            start.bg = "${blue}";
            stop.fg = "${background}";
            stop.bg = "${teal}";
            error.fg = "${red}";
          };

          hints = {
            fg = "${background}";
            bg = "${yellow}";
            match.fg = "${lighterGrey}";
          };

          keyhint = {
            fg = "${lighterGrey}";
            suffix.fg = "${lighterGrey}";
            bg = "${background}";
          };

          messages = {
            error.fg = "${background}";
            error.bg = "${red}";
            # error.border = "${red}";
            warning.fg = "${background}";
            warning.bg = "${magenta}";
            # warning.border = "${magenta}";
            info.fg = "${lighterGrey}";
            info.bg = "${background}";
            # info.border = "${background}";
          };

          prompts = {
            fg = "${lighterGrey}";
            border = "${background}";
            bg = "${background}";
            selected.bg = "${darkGrey}";
            selected.fg = "${lighterGrey}";
          };

          statusbar = {
            normal.fg = "${lighterGrey}";
            normal.bg = "${background}";
            insert.fg = "${teal}";
            insert.bg = "${background}";
            passthrough.fg = "${yellow}";
            passthrough.bg = "${background}";
            private.fg = "${magenta}";
            private.bg = "${background}";
            command.fg = "${lightGrey}";
            command.bg = "${darkerGrey}";
            command.private.fg = "${magenta}";
            command.private.bg = "${darkerGrey}";
            caret.fg = "${blue}";
            caret.bg = "${background}";
            caret.selection.fg = "${blue}";
            caret.selection.bg = "${background}";
            progress.bg = "${blue}";
            url.fg = "${lighterGrey}";
            url.error.fg = "${red}";
            url.hover.fg = "${orange}";
            url.success.http.fg = "${green}";
            url.success.https.fg = "${green}";
            url.warn.fg = "${magenta}";
          };

          tabs = {
            bar.bg = "${background}";
            indicator.start = "${blue}";
            indicator.stop = "${teal}";
            indicator.error = "${red}";
            odd.fg = "${lighterGrey}";
            odd.bg = "${background}";
            even.fg = "${lighterGrey}";
            even.bg = "${background}";
            pinned = {
              even.bg = "${green}";
              even.fg = "${background}";
              odd.bg = "${green}";
              odd.fg = "${background}";
              selected = {
                even.bg = "${darkGrey}";
                even.fg = "${lighterGrey}";
                odd.bg = "${darkGrey}";
                odd.fg = "${lighterGrey}";
              };
            };
            selected = {
              odd.fg = "${lighterGrey}";
              odd.bg = "${darkGrey}";
              even.fg = "${lighterGrey}";
              even.bg = "${darkGrey}";
            };
          };
        };
      };
    };
    firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        search.default = "DuckDuckGo";
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          darkreader
          bypass-paywalls-clean
          betterttv
          bitwarden
          clearurls
          ff2mpv
          no-pdf-download
          pay-by-privacy-com
          # pywalfox
          tridactyl
          sponsorblock
          return-youtube-dislikes
          enhancer-for-youtube
          # youchoose-ai
          youtube-shorts-block
          # zoom-page-we
          tree-style-tab
          terms-of-service-didnt-read
          # tab-stash
          # tabcenter-reborn
          protondb-for-steam
          languagetool
          i-dont-care-about-cookies
          gloc
          forget_me_not
          auto-tab-discard
        ];
        settings = {
          # Enables dark-themed flash before page-load:
          "ui.systemUsesDarkTheme" = "1";
          # Developer tools -> uses dark theme
          "devtools.theme" = "dark";
          "app.update.auto" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "media.av1.enabled" = false;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.hardware-video-decoding.force-enabled" = true;
          "media.navigator.mediadatadecoder_vpx_enabled" = true;
          "signon.rememberSignons" = false;
        };
      };
    };
    mako = {
      enable = true;
      defaultTimeout = 5000;
      icons = true;
      maxVisible = 3;
      font = "JetBrainsMono Nerd Font 12";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
  };

  programs.foot = {
    enable = true;
    settings = {
       main = {
        term = "xterm-256color";

        font = "JetBrainsMono Nerd Font:size=18";
        dpi-aware = "no";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };


  services.gammastep = {
    enable = true;
    latitude = 47.6055;
    longitude = -122.0356;
    temperature = {
      # day = 5000;
      night = 2000;
    };
    tray = true;
  };

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;
}
