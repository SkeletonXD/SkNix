{pkgs, ...}:
{
  users.users.skeletonxd = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "audio" "kvm" "video" "render" "bluetooth"
                    "libvirtd" "input" ];
  };

  home-manager.users.skeletonxd = {pkgs, ...}: {    
    programs = {
      helix = {
        enable = true;
        defaultEditor = true;
        extraConfig = "theme = \"zed_onedark\"";
      };

      kitty = {
        enable = true;
        settings = {
          background_opacity = "0.4";   
          dynamic_background_opacity = true;
        };
      };
    };
  
    systemd.user.services."mount-ramdisk-downloads" = {
      Unit = { Description = "Mount downloads to tmp"; };
      Service = {
        Type = "oneshot";
        ExecStart = "/bin/sh -c '${pkgs.coreutils}/bin/ln -sf $(${pkgs.coreutils}/bin/mktemp -d /tmp/downloads-XXXXXXXXX) /home/skeletonxd/Загрузки'";
        RemainAfterExit = true;
      };
      Install = { WantedBy = [ "default.target" ]; };
    };

    xdg.configFile."hypr/hypr.conf".text = ''
        # ---------- [GENERAL] ---------------------------------------------------------
gaps_in=5
border_size=1
gaps_out=20
rounding=25

max_fps=65
focus_when_hover=1
main_mod=SUPER
intelligent_transients=1

col.active_border=0x77ff3333
col.inactive_border=0x77222222

scratchpad_mon=0 

layout=0
layout {
    no_gaps_when_only=0
}

# ------- [WINDOW ANIMATIONS] -------------------------------------------------- 
Animations {
    enabled=1
    speed=5 # for workspaces
    window_resize_speed=5
    cheap=0
    borders=0
    workspaces=0
}

# ------------- [BAR] ----------------------------------------------------------
Bar {
    enabled=1
    height=20
    monitor=0
    mod_pad_in=8
    no_tray_saving=0
    font.main=Noto Sans Black
    font.secondary=Noto Sans Black

    col.bg=0xff111111
    col.high=0xffff3333

    module=left,X,0xff8000ff,0xffffffff,1,workspaces
    module=pad,left,10
    module=right,,0xff7000dd,0xff7000dd,1,tray
    module=center,,0xffffffff,0x77ff3333,1000,$date +%a,\ %-d\ %b.\ \ %r| tr -d '\n' && playerctl metadata -f "| \{\{title\}\} - \{\{artist\}\}"$
    module=right,,0xffffffff,0x77ff3333,100,$wpctl get-volume @DEFAULT_SINK@$
    module=right,,0xffffffff,0x77ff3333,100,$gamemoded -s$ |
}

# ----------- [ BINDS ] --------------------------------------------------------
bind=SUPER,R,exec,${pkgs.rofi} -show drun
bind=SUPER,T,exec,${pkgs.kitty}
bind=SUPER,M,exec,pkill Hypr
bind=SUPER,B,exec,app.zen_browser.zen
bind=SUPER,E,exec,Thunar
bind=SUPER,A,exec,${pkgs.ayugram-desktop}
bind=SHIFTSUPER,S,exec,${pkgs.scrot} -ifs - | ${pkgs.xclip} -selection clipboard -t image/png
bind=SUPER,Print,exec,${pkgs.scrot} -ifu - | ${pkgs.xclip} -selection clipboard -t image/png
bind=ALTSUPER,Print,exec,${pkgs.scrot} -if - | ${pkgs.xclip} -selection clipboard -t image/png

bind=SUPER,C,killactive,
bind=SUPER,F,fullscreen,
bind=SHIFTSUPER,F,togglefloating,
bind=SUPER,P,pseudo,

bind=,XF86AudioRaiseVolume,exec,wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+
bind=,XF86AudioLowerVolume,exec,wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%-
bind=,XF86AudioMute,exec,wpctl set-mute @DEFAULT_SINK@ toggle
# bind  = , XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
# Медиа-кнопки (работают даже когда Hypr заблокирован благодаря bindl)
bind=,XF86AudioPlay,exec,${pkgs.playerctl} play-pause
bind=,XF86AudioPause,exec,${pkgs.playerctl} play-pause
bind=,XF86AudioNext,exec,${pkgs.playerctl} next
bind=,XF86AudioPrev,exec,${pkgs.playerctl} previous
bind=,XF86AudioStop,exec,${pkgs.playerctl} stop

bind=SUPER,1,workspace,1
bind=SUPER,2,workspace,2
bind=SUPER,3,workspace,3
bind=SUPER,4,workspace,4
bind=SUPER,5,workspace,5
bind=SUPER,6,workspace,6
bind=SUPER,7,workspace,7
bind=SUPER,8,workspace,8
bind=SUPER,9,workspace,9

scratchpad_mon=0
bind=SUPER,S,scratchpad

bind=ALTSUPER,1,movetoworkspace,1
bind=ALTSUPER,2,movetoworkspace,2
bind=ALTSUPER,3,movetoworkspace,3
bind=ALTSUPER,4,movetoworkspace,4
bind=ALTSUPER,5,movetoworkspace,5
bind=ALTSUPER,6,movetoworkspace,6
bind=ALTSUPER,7,movetoworkspace,7
bind=ALTSUPER,8,movetoworkspace,8
bind=ALTSUPER,9,movetoworkspace,9

bind=SUPER,Home,lastworkspace,
bind=SUPER,End,nextworkspace,
bind=SUPER,up,movefocus,u
bind=SUPER,right,movefocus,r
bind=SUPER,down,movefocus,d
bind=SUPER,left,movefocus,l

bind=SUPER,L,exec,env XSECURELOCK_PASSWORD_PROMPT=time_hex XSECURELOCK_AUTH_SOUNDS=1 XSECURELOCK_SHOW_KEYBOARD_LAYOUT=0 ${pkgs.xsecurelock}

# ----------- [AUTORUN] --------------------------------------------------------
windowrule=workspace 9,class:Throne
exec-once=Throne
 

windowrule=workspace 2,class:AyuGram
exec-once=${pkgs.ayugram-desktop}


windowrule=workspace 1,class:app.zen_browser.zen
exec-once=app.zen_browser.zen


exec-once=${pkgs.xss-lock} -l -- env XSECURELOCK_PASSWORD_PROMPT=time_hex XSECURELOCK_AUTH_SOUNDS=1 XSECURELOCK_SHOW_KEYBOARD_LAYOUT=0 ${pkgs.xsecurelock}
exec=${pkgs.xrandr} --output VGA-0 --mode 1680x1050 --pos 0x30 --rotate normal --output DVI-D-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 1680x0 --rotate normal
exec=${pkgs.feh} --bg-center ~/Изображения/2.png ~/Изображения/1.png
      '';
    home.stateVersion = "25.11"  ;
  };
}
