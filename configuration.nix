{ lib, pkgs, inputs,  ... }:

{
  #----------[NIX CONFIGURATION]------------------------------------------------
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    trusted-substituters = [
      "https://cache.nixos.org/"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    trusted-public-keys = [
      # "mirrors.tuna.tsinghua.edu.cn:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  nix.package = pkgs.lix;
  
  #---------------[BOOT]--------------------------------------------------------
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod;
    tmp = {useTmpfs = true; cleanOnBoot = true;};
    loader.timeout = 5; 
    loader.grub = {
      enable = true;
      device = "/dev/sdb";
      gfxmodeBios = "1920x1080";
      gfxpayloadBios = "keep";
      timeoutStyle = "countdown";
      configurationLimit = 10;
      memtest86.enable = true;
    };
  };
  #-----------[OPTIMISATIONS]---------------------------------------------------
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.wg-quick-zhurman = {
    wantedBy = lib.mkForce [ "graphical.target" ];
    after = [ "graphical.target" "NetworkManager.service" ];
  };
  #-------------[SECURITY]------------------------------------------------------
  security = {
    polkit.enable = true;
    rtkit.enable = true;
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
  networking = {
    hostName = "SKNix";
    wireguard.enable = true;
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    wg-quick.interfaces.zhurman.configFile = "/etc/nixos/Zhurman.conf";
    firewall = {
      enable = true;
      checkReversePath = false;
      allowedTCPPorts = [25565 47584];
      allowedUDPPorts = [47584 51822];
    };
  };
  #-------------[LOCALE]--------------------------------------------------------
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = { LC_TIME = "en_US.UTF-8"; };
  console = {
    font = "cyr-sun16";
    useXkbConfig = true;
  };
  #------------[SERVICES]-------------------------------------------------------
  services = {
    desktopManager.plasma6.enable = true;
    #displayManager.plasma-login-manager.enable = true;
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
    flatpak = {
      enable = true;
      uninstallUnmanaged = true;
      update.onActivation = true;
      packages = ["app.zen_browser.zen"
                "net.davidotek.pupgui2" "com.usebottles.bottles"
                "com.vysp3r.ProtonPlus" "org.vinegarhq.Sober"
                "moe.launcher.an-anime-game-launcher" ];
    };
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
  #------------[GRAPHICS]-------------------------------------------------------
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    windowManager.hypr.enable = true;
    xkb = {layout = "us,ru"; options = "grp:win_space_toggle";};
  };
  services.displayManager.ly.enable = false;
  services.picom = {
    enable = false;
    backend = "glx";
    vSync = true;
    shadow = true;
    package = pkgs.picom-pijulius;
    settings = {
      corner-radius = 20;
      rounded-corners-exclude = [ "window_type = 'dock'" ];
      blur = {
        method = "dual_kawase";
        strength = 3;
      };
    };
  };
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
  #environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #  elisa konsole plasma-browser-integration
  #];
  xdg.portal = {enable = true; extraPortals = [ pkgs.xdg-desktop-portal-gtk ];};
  xdg.portal.configPackages = [ pkgs.gnome-session ];
  environment.systemPackages = with pkgs; [ simple-scan 
    tree helix kitty obsidian ffmpeg-headless ayugram-desktop git zellij
    inputs.elyprism.packages.${stdenv.hostPlatform.system}.default nixd nixfmt
    gnome-console
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
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
    starship.enable = true;
    firejail.enable = true;
    gamemode.enable = true;
    virt-manager.enable = true;
    gnupg.agent = { enable = true; enableSSHSupport = true; };
    zsh = {
      enable = true; enableCompletion = true; enableBashCompletion = true;
      autosuggestions.enable = true; syntaxHighlighting.enable = true;
      ohMyZsh = { enable = true; theme = "darkblood"; };
      shellAliases = {
        # # switch = "sudo nixos-rebuild switch --flake /etc/nixos#";
        # switch-on-boot = "sudo nixos-rebuild boot --flake /etc/nixos#";
        # test-switch = "sudo nixos-rebuild test --flake /etc/nixos#";
      };
    };
  };
  #-------------[SYSTEM]--------------------------------------------------------
  system = {
    stateVersion = "25.11";
  };
  #-----------
   services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # To disable installing GNOME's suite of applications
  # and only be left with GNOME shell.
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
}

