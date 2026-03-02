{ config, lib, pkgs, ... }:

{
  programs.fuse.userAllowOther = true;

  systemd.mounts = [{
    what = "root@192.168.0.6:/homeassistant";
    where = "/home/mattias/mounts/homeassistant";
    type = "fuse.sshfs";
    options = "identityfile=/root/.ssh/id_ed25519_ha_sshfs,allow_other,default_permissions,reconnect,ServerAliveInterval=15,_netdev,uid=1000,gid=100";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  }];

  systemd.automounts = [{
    where = "/home/mattias/mounts/homeassistant";
    wantedBy = [ "multi-user.target" ];
    automountConfig.TimeoutIdleSec = "600";
  }];
}
