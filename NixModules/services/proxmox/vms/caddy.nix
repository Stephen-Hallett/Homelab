{ pkgs, lib, config, ... }: {
  config = lib.mkIf config.nix-config.proxmox.enable {
    services.proxmox-ve.vms = {
      "caddy" = {
        vmid = 101;
        memory = 1024;
        cores = 1;
        sockets = 1;
        net = [
          {
            model = "virtio";
            bridge = "vmbr0";
          }
        ];
        scsi = [ { file = "ProxmoxVMs:8"; } ];
        ide = [{
          file = "ProxmoxVMs:iso/latest-nixos-minimal-x86_64-linux.iso";
          media = "cdrom";
        }];
      };
    };
  };
}
