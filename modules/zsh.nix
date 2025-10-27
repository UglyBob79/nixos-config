{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "docker" ];
    theme = "bira";
  };
}
