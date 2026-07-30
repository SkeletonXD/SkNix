{pkgs, ...}:
{
  users.users.miraruen = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "audio" "kvm" "video" "render" "bluetooth"
                    "libvirtd" "input" "scanner" "lp" ];
  };
  home-manager.users.miraruen = {...}: {    
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
    home.stateVersion = "25.11";
  };
}
