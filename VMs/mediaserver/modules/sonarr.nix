{
  pkgs-unstable,
  lib,
  config,
  ...
}:
let
  sonarrConfigDir = "/mnt/NFS-Storage/Data/nix-mediaserver/sonarr";
in
{
  options = {
    media-modules.sonarr.enable = lib.mkEnableOption "enable sonarr";
  };

  config = lib.mkIf config.media-modules.sonarr.enable {
    services.sonarr = {
      enable = true;
      openFirewall = true;
      package = pkgs-unstable.sonarr;
      dataDir = sonarrConfigDir;
      user = "stephen";
      group = "sonarr";
      settings.server.port = 8989;
    };
    systemd.tmpfiles.rules = [
      "d /mnt/NFS-Storage/Data/nix-mediaserver/sonarr 0775 stephen sonarr -"
    ];

    users.users.stephen.extraGroups = [ "sonarr" ];
  };
}