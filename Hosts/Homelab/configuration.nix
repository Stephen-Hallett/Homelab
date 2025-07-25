# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./../Core/configuration.nix
    ./hardware-configuration.nix
  ];

  nix-config = {
    bluetooth.enable = true;
    immich.enable = true;
    sunshine.enable = true;
    proxmox.enable = true;
    headless.enable = false;
    desktop.enable = true;
    code-server.enable = true;
    swap.enable = true;
    steam.enable = true;
    tailscale.enable = true;
    networking.enable = true;
    coding.enable = true;
    docker.enable = true;
    fonts.enable = true;
    neovim.enable = true;
    tdarr-node.enable = true;
    nextcloud.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8814au ];
  boot.loader.grub.enable = false;

  hardware.enableAllFirmware = true;

  networking.hostName = "homelab"; # Define your hostname.
  networking.wireless.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

}
