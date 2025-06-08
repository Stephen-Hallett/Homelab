{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../Hosts/VM/configuration.nix
  ];

  nix-config = {
    tailscale.enable = false;
  };

  networking.hostName = "tdarr";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}