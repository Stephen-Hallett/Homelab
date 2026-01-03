{ pkgs-unstable, lib, config, ... }: {
  options = {
    nix-config.mealie.enable = lib.mkEnableOption "enable mealie";
  };

  config = lib.mkIf config.nix-config.mealie.enable {
    # Ensure the NAS directory exists with correct permissions
    systemd.tmpfiles.rules = [ 
      "d /mnt/NFS-Storage/mealie 0755 mealie mealie -"
    ];

    services.mealie = {
      enable = true;
      package = pkgs-unstable.mealie;
      listenAddress = "0.0.0.0";
      port = 9000;
      
      # Override the DATA_DIR to point to your NAS
      settings = {
        DATA_DIR = "/mnt/NFS-Storage/mealie";
        TZ = "Pacific/Auckland";

        # Catppuccin Latte (Light Theme)
        THEME_LIGHT_PRIMARY = "#7287fd";    # Lavender (primary brand color)
        THEME_LIGHT_ACCENT = "#7287fd";     # Lavender (buttons/interactive)
        THEME_LIGHT_SECONDARY = "#04a5e5";  # Sky (navigation/sidebar)
        THEME_LIGHT_SUCCESS = "#40A02B";    # Green
        THEME_LIGHT_INFO = "#1E66F5";       # Blue
        THEME_LIGHT_WARNING = "#FE640B";    # Peach
        THEME_LIGHT_ERROR = "#D20F39";      # Red
        
        # Catppuccin Macchiato (Dark Theme)
        THEME_DARK_PRIMARY = "#b7bdf8";     # Lavender (primary brand color)
        THEME_DARK_ACCENT = "#b7bdf8";      # Lavender (buttons/interactive)
        THEME_DARK_SECONDARY = "#91d7e3";   # Sky (navigation/sidebar)
        THEME_DARK_SUCCESS = "#A6DA95";     # Green
        THEME_DARK_INFO = "#8AADF4";        # Blue
        THEME_DARK_WARNING = "#F5A97F";     # Peach
        THEME_DARK_ERROR = "#ED8796";       # Red
      };
      
      database.createLocally = false;  # Set to true if you want PostgreSQL
    };

    # Since the service uses DynamicUser, we need to ensure the mealie user
    # has access to the NAS directory
    systemd.services.mealie.serviceConfig = {
      # Remove DynamicUser to use a static user
      DynamicUser = lib.mkForce false;
    };

    # Create a static mealie user
    users.users.mealie = {
      isSystemUser = true;
      group = "mealie";
    };

    users.groups.mealie = {};
  };
}