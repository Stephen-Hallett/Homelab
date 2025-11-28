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
    jellyfin.enable = true;
    mediastack.enable = true;
    prowlarr.enable = false;
    sonarr.enable = true;
    radarr.enable = true;
};

  nix-config = {
    docker.enable = true;
    tailscale.enable = true;
  };

  networking.hostName = "mediaserver";

  fileSystems."/mnt/NFS-Storage" = {
    device = "192.168.1.152:/mnt/Mediastack";
    fsType = "nfs";
    options = [ "defaults" "noatime" "vers=3" "_netdev" ];
    neededForBoot = false;
  };

  systemd.tmpfiles.rules = [ 
    "d /mnt/NFS-Storage 0755 root root -" 
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

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