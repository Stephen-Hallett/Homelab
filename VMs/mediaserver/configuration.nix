{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../Hosts/VM/configuration.nix
    ./modules
    ./../../NixModules/services/tailscale.nix
  ];

  media-modules = {
    jellyseerr.enable = true;
    mediastack.enable = true;
};

  nix-config = {
    docker.enable = true;
    tailscale.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
    cifs-utils
    dig
  ];


  networking.hostName = "mediaserver";

  fileSystems."/mnt/NFS-Storage" = {
    device = "192.168.1.152:/mnt/Mediastack";
    fsType = "nfs";
    options = [ "defaults" "noatime" "vers=3" "_netdev" ];
    neededForBoot = false;
  };

  fileSystems."/tank" = {
    device = "192.168.1.72:/tank/mediastack";
    fsType = "nfs";

    options = [
      "defaults"
      "x-systemd.automount"
      "noatime"
      "nfsvers=4"
      "_netdev"
    ];
  };

  systemd.tmpfiles.rules = [ 
    "d /mnt/NFS-Storage 0755 root root -" 
    "d /tank 0775 root root -"
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 2049 ];
  networking.firewall.allowedUDPPorts = [ 2049 ];

  # Declare all the secrets
  sops.secrets = {
    "mediastack/docker_subnet" = {
      owner = config.users.users.stephen.name;
      inherit (config.users.users.stephen) group;
    };
    "mediastack/docker_gateway" = {
      owner = config.users.users.stephen.name;
      inherit (config.users.users.stephen) group;
    };
    "mediastack/vpn_user" = {
      owner = config.users.users.stephen.name;
      inherit (config.users.users.stephen) group;
    };
    "mediastack/vpn_password" = {
      owner = config.users.users.stephen.name;
      inherit (config.users.users.stephen) group;
    };
    "mediastack/local_subnet" = {
      owner = config.users.users.stephen.name;
      inherit (config.users.users.stephen) group;
    };
  };
}