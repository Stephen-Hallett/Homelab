{
  pkgs-unstable,
  lib,
  config,
  ...
}:
let
  jellyfinConfigDir = "/tank/mediastack/Data/jellyfin";
  jellyfinMediaDir = "/tank/mediastack/Media";
in
{
  options = {
    media-modules.jellyfin.enable = lib.mkEnableOption "enable jellyfin";
  };

  config = lib.mkIf config.media-modules.jellyfin.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      dataDir = jellyfinConfigDir;
      user = "stephen";
      group = "users";
      package = pkgs-unstable.jellyfin;
      # port 8096
    };
    environment.systemPackages = with pkgs-unstable; [
      jellyfin-web
      jellyfin-ffmpeg
    ];
    systemd.tmpfiles.rules = [
      "d /tank/mediastack/Data/jellyfin 0775 stephen users -"
    ];
  };
}