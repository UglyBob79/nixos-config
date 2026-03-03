{ config, pkgs, lib, ... }:

{
  options.codeServer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable code-server web IDE (access via SSH tunnel)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for code-server to listen on";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "mattias";
      description = "User to run code-server as";
    };

    hashedPassword = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Hashed password for authentication. Leave empty to disable auth.
        Generate with: nix-shell -p libargon2 --run "echo -n 'yourpassword' | argon2 \$(head -c 16 /dev/urandom | base64) -id -e"
      '';
    };
  };

  config = lib.mkIf config.codeServer.enable {

    # Required for VSCode extensions that ship pre-compiled binaries
    programs.nix-ld.enable = true;

    services.code-server = {
      enable = true;
      host = "0.0.0.0";
      port = config.codeServer.port;
      user = config.codeServer.user;
      auth = if config.codeServer.hashedPassword != "" then "password" else "none";
      hashedPassword = config.codeServer.hashedPassword;
    };
  };
}
