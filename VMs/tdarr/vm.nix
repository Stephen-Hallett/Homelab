{ pkgs, lib, config, ... }: {
  config = lib.mkIf config.nix-config.proxmox.enable {
    services.proxmox-ve.vms.tdarr = {
        vmid = 202;
        memory = 8192;
        cores = 4;
        sockets = 2;
        net = [
          {
            model = "virtio";
            bridge = "vmbr0";
          }
        ];
        scsi = [ { file = "ProxmoxVMs:16"; } ];
        cdrom = "ProxmoxVMs:iso/latest-nixos-minimal-x86_64-linux.iso";
        bios = "ovmf";
        onboot = true;
    };

    networking.extraHosts = ''
      192.168.1.84 tdarr
    '';
  };
}
