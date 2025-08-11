# Making declarative(ish) vms:

- Make a new vm.nix file in a folder for your new vm. Make sure you rename the "services.proxmox-ve.vms.XXXXX" section, and alter the vmid to be an unused value.
- Access the vm in proxmox, and give the root user a password using

```bash
sudo passwd
```

- Get the vms ip address using "ip a"
- run the following to set up the base vm nix config & disk confugration with disko. Replace "IP_ADDRESS" with the address acquired from the last step

```bash
nix run nixpkgs#nixos-anywhere -- --flake /home/stephen/Homelab#vm --generate-hardware-config nixos-generate-config ./Hosts/VM/hardware-configuration.nix root@IP_ADDRESS
```

- Add an entry into the flake.nix referencing the configuration.nix file in the new vms folder
- Run the following to install your configuration, replacing IP_ADDRESS & VM_NAME accordingly

```bash
sudo nixos-rebuild switch --target-host stephen@IP_ADDRESS --use-remote-sudo --impure --flake ~/Homelab#VM_NAME
```

- Revisit the vm.nix file, and add the vm's ip address & hostname to the "networking.extraHosts" section, and rebuild the homelab. From now on you can rebuild the vm with "rbvm HOSTNAME"

#### For VM's that need SOPS

SOPS will be unable to decrypt secrets on the VM until the VM is added as a trusted host. To do this, do the following.

- SSH into the vm with "ssh HOSTNAME"
- run the following to get the public age key:

```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

- Copy the key, and add it to Hosts/Core/.sops.yaml
- cd into Hosts/Core and run the following to update the keys

```bash
sops updatekeys secrets/secrets.yaml
```

- Rebuild your vm with "rbvm HOSTNAME" and sops will be able to decrypt your secrets!

> [!TIP]
> To get tailscale to show the right hostname, reboot your vm
