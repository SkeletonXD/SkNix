{ config, lib, pkgs, gnomex11, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];
  #----------[NIX CONFIGURATION]------------------------------------------------
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
 #     "https://cache.garnix.io"
 #     "https://nix-community.cachix.org"
    ];
    trusted-substituters = [
      "https://cache.nixos.org/"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
 #     "https://cache.garnix.io"
 #     "https://nix-community.cachix.org"
 #     "https://prismlauncher.cachix.org"
    ];
    trusted-public-keys = [
      "prismlauncher.cachix.org:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="
      "mirrors.tuna.tsinghua.edu.cn:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  #---------------[BOOT]--------------------------------------------------------
  boot = {
    plymouth = {
      enable = false;
    #  themePackages = with pkgs; [adi1090x-plymouth-themes];
    #  theme = "black_hud";
    };
    kernelPackages = pkgs.linuxPackages_xanmod;
    tmp = {useTmpfs = true; cleanOnBoot = true;};
    loader.timeout = 0; 
    loader.grub = {
      enable = true;
      device = "/dev/sdb";
      useOSProber = true;
#      gfxpayloadBios = "keep";
#      gfxmodeBios = "1920x1080";
      timeoutStyle = "hidden";
      configurationLimit = 10;
      memtest86.enable = true;
      # splashMode = "normal"; 
    };
  };
  #-----------[OPTIMISATIONS]---------------------------------------------------
  systemd.services.NetworkManager-wait-online.enable = false;
#  services.upower.enable = lib.mkForce false;
  systemd.services.wg-quick-zhurman = {
    wantedBy = lib.mkForce [ "graphical.target" ];
    after = [ "graphical.target" "NetworkManager.service" ];
  };
  
  networking.firewall.checkReversePath = false;
  #-------------[SECURITY]------------------------------------------------------
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    isolate.enable = true;
  };
  services.clamav = {
    updater.enable = true; updater.interval = "hourly"; scanner.enable = false;
    fangfrisch.enable = true; fangfrisch.interval = "daily";
    daemon.enable = true; clamonacc.enable = false;
  };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;
  };
  #-------------[NETWORK]-------------------------------------------------------
  #services.resolved.enable = lib.mkForce false;
  networking = {
    hostName = "SKNix";
    wireguard.enable = true;
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    wg-quick.interfaces.zhurman.configFile = "/etc/nixos/Zhurman.conf";
    firewall = {
      enable = false;
      allowedTCPPorts = [25565 47584];
      allowedUDPPorts = [47584 51822];
    };
  };
  #-------------[LOCALE]--------------------------------------------------------
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console = {
    font = "cyr-sun16";
    useXkbConfig = true;
  };
  #------------[SERVICES]-------------------------------------------------------
  services = {
    zapret = {
      enable = true;
      udpSupport = true;
      udpPorts = [ "1024:65535" ];
      params = [ "--dpi-desync-any-protocol"
            "--filter-tcp=443 --dpi-desync=multidisorder --dpi-desync-split-pos=2"
            "--new --filter-udp=1024-65535 --dpi-desync-any-protocol --dpi-desync=fake --dpi-desync-repeats=8"
              #"--hostlist-domains=nixos.org --dpi-desync=multisplit --dpi-desync-split-pos=2"
              #"--new --hostlist-domains=google.com,youtu.be,youtube.com,ytimg.com,googlevideo.com,youtubei.googleapis.com,ggpht.com --dpi-desync=multidisorder --dpi-desync-split-pos=host+1,midsld"
              #"--new --hostlist-domains=rbxcdn.com,roblox.com --dpi-desync=multidisorder --dpi-desync-split-pos=host+1,midsld"
              #"--new --filter-udp=1024-65535 --hostlist-domains=rbxcdn.com,roblox.com --dpi-desync=fake --dpi-desync-repeats=12 --dpi-desync-any-protocol --dpi-desync-cutoff=n2 --dpi-desync-fake-unknown-udp=quic_initial_www_google_com.bin"
              # "--new --hostlist-domains=zerotier.com --dpi-desync=multisplit --dpi-desync-split-pos=method+2,midsld"
              # "--new --hostlist-domains=cloudflareclient.com,cloudflare.com --dpi-desync=multidisorder --dpi-desync-split-pos=sniext+1"
              # "--new --hostlist-domains=roblox.com --dpi-desync=multidisorder --dpi-desync-split-pos=2"
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    openssh.enable = true;
    zerotierone = {
      enable = false;
      joinNetworks = [ "56374ac9a498410a" ];
    };
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    #v2raya.enable = true;
    cloudflare-warp = {
      enable = true;
      openFirewall = true;
    };
    flatpak.enable = true;
    udev.packages = with pkgs; [ hplipWithPlugin ];
    printing = {
      enable = true;
      drivers = with pkgs; [ hplipWithPlugin ];
      listenAddresses = [ "localhost:631" "192.168.0.2:631" ];
      allowFrom = [ "all" ];
      browsing = true;
      openFirewall = true;
    };
    dnsproxy = {
      enable = false;
      settings = { listen = [ "127.0.0.1:53" "[::1]:53" ];
        upstream = [
          "tls://xbox-dns.ru" "tls://dns.comss.one"
          "https://xbox-dns.ru/dns-query" "https://dns.comss.one/dns-query"
        ];
        bootstrap = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
        cache = false; verbose = true;
      };
    };
  };
  #--------------[USER]---------------------------------------------------------
  users.users.skeletonxd = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "audio" "kvm" "video" "render" "bluetooth"
                    "libvirtd" "input" ];
  };
  #------------[GRAPHICS]-------------------------------------------------------
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    desktopManager.xfce.enable = false;
    windowManager.hypr.enable = true;
    xkb = {layout = "us,ru"; options = "grp:win_space_toggle";};
  };
  services.displayManager.ly.enable = true;
  environment.variables = {
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json:/run/opengl-driver/share/egl/egl_external_platform.d/10_nvidia_wayland.json";
    __GLX_VENDOR_LIBRARY_NAME="nvidia";
  };
  
  #-------------[AUDIO]---------------------------------------------------------
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  #------------[SOFTWARE]-------------------------------------------------------
  xdg.portal = {enable = true; extraPortals = [ pkgs.xdg-desktop-portal-gtk ];};
  xdg.portal.configPackages = [ pkgs.gnome-session ];
  environment.systemPackages = with pkgs; [
    tree neovim kitty ayugram-desktop gnome-text-editor rofi scrot feh xclip 
    playerctl xsecurelock xss-lock
  ];
  programs = {
    mtr.enable = true;
    throne = {
      enable = true;
      tunMode = {
        setuid = true;
        enable = true;
      };
    };
    thunar = {
      enable = true;
      plugins = with pkgs; [ thunar-archive-plugin thunar-vcs-plugin
                             thunar-media-tags-plugin thunar-volman];
    };
    xfconf.enable = true;
    starship.enable = true;
    gamemode.enable = true;
    virt-manager.enable = true;
    gnupg.agent = { enable = true; enableSSHSupport = true; };
    zsh = {
      enable = true; enableCompletion = true; enableBashCompletion = true;
      autosuggestions.enable = true; syntaxHighlighting.enable = true;
      ohMyZsh = { enable = true; theme = "darkblood"; };
      shellAliases = {
        #nix-shell = "nix-shell --log-format bar-with-logs";
        switch = "sudo nixos-rebuild switch --flake /etc/nixos#";
        switch-on-boot = "sudo nixos-rebuild boot --flake /etc/nixos#";
        test-switch = "sudo nixos-rebuild test --flake /etc/nixos#";
      };
    };
  };
  #-------------[SYSTEM]--------------------------------------------------------
  system = {
    #copySystemConfiguration = true;
    stateVersion = "25.11";
  };
}

