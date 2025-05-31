{ pkgs, lib, config, ... }: {
  options = {
    nix-config.caddy.enable = lib.mkEnableOption "enable caddy";
  };

  config = lib.mkIf config.nix-config.caddy.enable {
    services.caddy = {
      enable = true;
      user = "stephen";
      email = "stevohallett@gmail.com";
    };
  };
}
