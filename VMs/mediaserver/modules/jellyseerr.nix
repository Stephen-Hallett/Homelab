{
  pkgs-unstable,
  lib,
  config,
  ...
}:
{
  options = {
    media-modules.jellyseerr.enable = lib.mkEnableOption "enable jellyseerr";
  };

  config = lib.mkIf config.media-modules.jellyseerr.enable {
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
      port = 5055;
      package = pkgs-unstable.jellyseerr;
    };
  };
}