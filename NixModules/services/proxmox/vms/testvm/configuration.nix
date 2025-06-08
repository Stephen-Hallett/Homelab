{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./../../../../../Hosts/VM/configuration.nix
    ./../../../tailscale.nix
  ];

  nix-config = {
    tailscale.enable = true;
  };

  networking.hostName = "testvm";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}