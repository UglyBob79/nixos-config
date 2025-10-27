{ config, pkgs, ... }:

{
  # Enable Docker daemon
  virtualisation.docker.enable = true;

  # Install Docker Compose
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
