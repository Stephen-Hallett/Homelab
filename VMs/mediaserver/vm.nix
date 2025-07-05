{ pkgs, lib, config, ... }: {
  config = lib.mkIf config.nix-config.proxmox.enable {
    services.proxmox-ve.vms.mediaserver = {
        vmid = 203;
        memory = 8192;
        cores = 2;
        sockets = 2;
        net = [
          {
            model = "virtio";
            bridge = "vmbr0";
          }
        ];
        scsi = [ { file = "ProxmoxVMs:64"; } ];
        cdrom = "ProxmoxVMs:iso/latest-nixos-minimal-x86_64-linux.iso";
        bios = "ovmf";
        onboot = true;
    };

    networking.extraHosts = ''
      192.168.1.37 mediaserver
    '';
  };
}
