{ pkgs, lib, config, ... }: {
  options = {
    nix-config.nextcloud.enable = lib.mkEnableOption "enable nextcloud";
  };

  config = lib.mkIf config.nix-config.nextcloud.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = "nextcloud.hosted";
      database.createLocally = true;
      configureRedis = true;
      https = true;

      config = {
        dbtype = "mysql";
        adminuser = "stephen";
        adminpassFile = "${config.sops.secrets.nextcloudpassword.path}";
      };
      settings = {
        mysql.utf8mb4 = true;
        trusted_domains = [
          "homelab.panthera-chickadee.ts.net"
          "nextcloud.hosted.stephenhallett.nz"
          "100.76.206.4"
        ];
      };
      maxUploadSize = "32G";
      phpOptions = {
        "opcache.interned_strings_buffer" = "16";
      };
      extraAppsEnable = true;
      extraApps = {
        inherit (pkgs.nextcloud31Packages.apps) mail calendar contacts;
      };
    };

    services.nginx = {
      enable=true;
      virtualHosts."nextcloud.hosted".listen = [ { addr = "100.76.206.4"; port = 1000; } ];
    };
  };
}