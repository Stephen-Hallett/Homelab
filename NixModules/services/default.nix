{
  imports = [
    ./networking.nix
    ./sunshine.nix
    ./proxmox/proxmox.nix
    ./headless.nix
    ./desktop.nix
    ./code-server.nix
    ./tailscale.nix
  ];
}
