{ config, pkgs, lib, ... }:

let
  wikiUser = "wiki";
  wikiDir  = "/var/lib/gollum";
in
{
  options.gollum = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Gollum wiki service";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 4567;
      description = "Port for Gollum wiki";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = wikiUser;
      description = "System user for Gollum";
    };

    directory = lib.mkOption {
      type = lib.types.str;
      default = wikiDir;
      description = "Working directory for the wiki";
    };
  };

  config = lib.mkIf config.gollum.enable {

    # Install necessary packages
    environment.systemPackages = with pkgs; [
      gollum
      git
    ];

    # Create wiki group and user
    users.groups.wiki = {};

    users.users.${config.gollum.user} = {
      isSystemUser = true;
      description = "Gollum Wiki user";
      home = config.gollum.directory;
      createHome = true;
      shell = pkgs.bash;
      group = "wiki";
    };

    # Ensure directory exists with proper ownership
    systemd.tmpfiles.rules = [
      "d ${config.gollum.directory} 0755 ${config.gollum.user} wiki -"
    ];

    # Initialize Git repo automatically if missing
    systemd.services.gollum-init = {
      description = "Initialize Gollum Wiki repository";
      wantedBy = [ "multi-user.target" ];
      before = [ "gollum.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = config.gollum.user;
        WorkingDirectory = config.gollum.directory;
        ExecStart = ''
          ${pkgs.git}/bin/git init ${config.gollum.directory}
          # Create default Home.md if none exists
          if [ ! -f ${config.gollum.directory}/Home.md ]; then
            echo "# Welcome to Gollum Wiki" > ${config.gollum.directory}/Home.md
            ${pkgs.git}/bin/git add Home.md
            ${pkgs.git}/bin/git commit -m "Add default Home.md"
          fi
        '';
        ConditionPathExists = "!${config.gollum.directory}/.git";
      };
    };

    # Gollum systemd service
    systemd.services.gollum = {
      description = "Gollum Wiki";
      after = [ "network.target" "gollum-init.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = config.gollum.user;
        WorkingDirectory = config.gollum.directory;
        ExecStart = "${pkgs.gollum}/bin/gollum --host 0.0.0.0 --port ${toString config.gollum.port}";
        Restart = "on-failure";
      };
    };
  };
}
