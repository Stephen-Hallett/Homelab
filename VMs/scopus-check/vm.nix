{ pkgs, lib, config, ... }: {
  config = lib.mkIf config.nix-config.proxmox.enable {
    services.proxmox-ve.vms.scopus-check = {
        vmid = 204;
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
        cdrom = "ProxmoxVMs:iso/latest-nixos-minimal-x86_64-linux.iso";
        bios = "ovmf";
        onboot = true;
    };

    networking.extraHosts = ''
      192.168.1.66 scopus-check
    '';
  };
}
