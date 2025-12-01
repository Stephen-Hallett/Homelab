# Config for packages shared by all machines
{ pkgs, lib, ... }: {
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs = { config = { allowUnfree = true; }; };

  home = {
    stateVersion = "25.05";
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";

    packages = with pkgs; [
      git
      home-manager
      nerd-fonts.fantasque-sans-mono
      wget
      curl
      nerd-fonts.symbols-only
      neofetch
      yarn

      nfs-utils
      usbutils
      pciutils
      cifs-utils
      dig
      fd
    ];
  };

  services.unclutter = {
    enable = true;
    timeout = 5; # Hide cursor after 5 seconds of inactivity
    threshold =
      10; # Minimum number of pixels cursor must move to be considered active
  };

  fonts.fontconfig.enable = true;

  core-packages = {
    ruff.enable = false;
    fzf.enable = true;
    bat.enable = true;
    zsh.enable = true;
    zoxide.enable = true;
    starship.enable = true;
    nixvim.enable = true;
    eza.enable = true;
    git.enable = true;
    ripgrep.enable = true;
  };

  systemd.user.services.mymirror = let
    startScript = pkgs.writeShellScript "mymirror-start" ''
      cd $HOME/myMirror/electron
      ${pkgs.yarn}/bin/yarn install
      exec ${pkgs.yarn}/bin/yarn start
    '';
  in {
    Unit = {
      Description = "myMirror Electron App";
      After = [ "graphical-session.target" ];
    };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      Type = "simple";
      Environment = [ "DISPLAY=:0" "XAUTHORITY=%h/.Xauthority" ];
      ExecStart = "${startScript}";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  systemd.user.services.unclutter = {
    Unit = { After = [ "graphical-session.target" ]; };
    Service = { Environment = [ "DISPLAY=:0" "XAUTHORITY=%h/.Xauthority" ]; };
  };
}
