{ personal, lib, config, ... }: {
  options = { core-packages.git.enable = lib.mkEnableOption "enable git"; };

  config = lib.mkIf config.core-packages.git.enable {
    programs.git = {
      enable = true;
      userName = "${personal.gitUser}";
      userEmail = "${personal.gitEmail}";

      aliases = { tree = "log --all --graph --decorate"; };

      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;

        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "~/.ssh/id_ed25519";
      };

      delta = {
        enable = true;
        options = {
          navigate = true;
          side-by-side = true;
        };
      };
    };
  };
}
