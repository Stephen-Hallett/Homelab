{ pkgs, pkgs-unstable, lib, config, ... }:
{
  options = {
    nix-config.tailscale.enable = lib.mkEnableOption "enable tailscale";
  };

  config = lib.mkIf config.nix-config.tailscale.enable {
    environment.systemPackages = [ pkgs-unstable.tailscale ];
    
    services.tailscale = {
      enable = true;
      package = pkgs-unstable.tailscale;
      authKeyFile = config.sops.secrets.tailscale.path;
    };

    networking.firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 ];
    };     
  };
}