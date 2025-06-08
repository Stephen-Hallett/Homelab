{ personal, config, inputs, pkgs, ... }:

{
  imports = [ 
    ./../../NixModules 
    inputs.sops-nix.nixosModules.sops
  ];

  nix.settings.trusted-users = [ "root" "@wheel" ];

  nix-config = {
    home-manager.enable = true;
    shell-config.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  powerManagement.enable = false;

  # Delete configurations older than 7 days
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Set your time zone.
  time.timeZone = "${personal.timeZone}";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stephen = {
    isNormalUser = true;
    description = "Stephen Hallett";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./ssh/id_homewsl.pub) # Home WSL
      (builtins.readFile ./ssh/id_homemac.pub) # Home Macbook
      (builtins.readFile ./ssh/id_homelab.pub) # Homelab
    ];
    hashedPassword="$6$J4gYl8oepiSEZTFi$VReuvn2W7NDCLKXQjLjWnhm2gaDhYnvOYt9g2c.f6YNB2CwwtGR.FFoiLES4buTPuD.ONYj5tVW7/DrGI1sby1";
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "stephen";

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      generateKey = true;
      keyFile = "/home/stephen/.config/sops/age/keys.txt";
    };

    secrets = {
      cloudflare = {
        owner = config.users.users.stephen.name;
        inherit (config.users.users.stephen) group;
      };
      tailscale = {
        owner = config.users.users.stephen.name;
        inherit (config.users.users.stephen) group;
      };
      "private_keys/homelab" = {
        path = "/home/stephen/.ssh/id_ed25519";
        owner = config.users.users.stephen.name;
        inherit (config.users.users.stephen) group;
      };
    };
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
