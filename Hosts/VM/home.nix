{ pkgs, ... }: {
  imports = [ ./../Core/home.nix ];

  home = {
    packages = with pkgs; [
      # Docker
      docker
      docker-compose
      containerd
    ];
  };
}
