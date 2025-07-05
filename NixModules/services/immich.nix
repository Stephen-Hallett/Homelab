{ lib, config, ... }: {
  options = {
    nix-config.immich.enable = lib.mkEnableOption "enable immich";
  };

  config = lib.mkIf config.nix-config.immich.enable {
    systemd.tmpfiles.rules = [ 
      "d /mnt/NFS-Storage/Photos 0755 immich immich -"
    ];

    users.users.stephen.extraGroups = ["immich"];

    services.immich = {
        enable = true;
        machine-learning.enable = true;
        redis.enable = true;
        database = {
            enable = true;
            createDB = true;
        };

        accelerationDevices = null;
        mediaLocation = "/mnt/NFS-Storage/Photos";

        openFirewall = true;
        port = 2283;
        host = "0.0.0.0";
    };

    networking.firewall.allowedTCPPorts = [ 2283 ];
  };
}