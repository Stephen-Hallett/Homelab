{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../Hosts/VM/configuration.nix
    ./../../NixModules/services/tailscale.nix
  ];

  nix-config = {
    tailscale.enable = true;
  };

  networking.hostName = "testvm";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}