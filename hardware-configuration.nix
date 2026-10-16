{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "xhci_pci" "uas" "usbhid" "sd_mod" "sr_mod" ];
#  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelModules = [ "kvm-intel" "ntsync" ];
  boot.extraModulePackages = [ ];
  boot.blacklistedKernelModules = [ "simpledrm" ];
  boot.kernelParams = [  "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" "video=HDMI-A-1:1920x1080@60" "video=VGA-1:1680x1050@60" "video=DVI-D-0:d" "fbcon=map:01" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5afe0695-7bb4-4c67-bf1e-2dfdc7f65759";
      fsType = "btrfs";
      options = [ "subvol=nixroot" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/5afe0695-7bb4-4c67-bf1e-2dfdc7f65759";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime"];
    };

  swapDevices = [ ];
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.blueman.enable = true;

  hardware = {
    block.defaultScheduler = "bfq";
    enableAllHardware = true;
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver egl-wayland ];
      extraPackages32 = with pkgs; [
        nvidia-vaapi-driver];
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      modesetting.enable = true;
      powerManagement = {
	enable = false;
	finegrained = false;
      };
    };
    bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy.AutoEnable = true;
      };
    };
    sane = {
      enable = true;
      extraBackends = [ pkgs.epkowa ];
    };
  };
}
