{
  pkgs,
  lib,
  config,
  ...
}:
let
  radarrConfigDir = "/mnt/NFS-Storage/Data/nix-mediaserver/radarr";
in
{
  options = {
    media-modules.radarr.enable = lib.mkEnableOption "enable radarr";
  };

  config = lib.mkIf config.media-modules.radarr.enable {
    services.radarr = {
      enable = true;
      openFirewall = true;
      package = pkgs.radarr;
      dataDir = radarrConfigDir;
      user = "stephen";
      group = "radarr";
      settings.server.port = 7878;
    };
    systemd.tmpfiles.rules = [
      "d /mnt/NFS-Storage/Data/nix-mediaserver/radarr 0775 stephen radarr -"
    ];
    users.users.stephen.extraGroups = [ "radarr" ];
  };
}