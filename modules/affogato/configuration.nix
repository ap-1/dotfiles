{ config, ... }:
let
  meta = config.flake.meta;
  hosts = config.flake.hosts;
in
{
  flake.modules.nixos.affogato-configuration =
    {
      config,
      pkgs,
      ...
    }:
    {
      age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
      age.secrets.headscale-authkey-affogato = {
        file = ../../secrets/headscale-authkey-affogato.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      services.tailscale.authKeyFile = config.age.secrets.headscale-authkey-affogato.path;

      networking.hostName = "affogato";

      services.cloud-init.enable = false;

      # cloud-init is off, so configure the hetzner interface for systemd-networkd
      systemd.network.networks."30-wan" = {
        matchConfig.Name = "enp1s0"; # hetzner cloud virtio NIC
        networkConfig.DHCP = "ipv4";
        address = [ "${hosts.affogato.publicIpv6}/64" ];
        routes = [ { Gateway = "fe80::1"; } ]; # hetzner link-local gateway
      };

      services.openssh = {
        openFirewall = false;
        settings.PasswordAuthentication = false;
      };

      networking.firewall = {
        interfaces.tailscale0.allowedTCPPorts = [ 22 ];
        allowedTCPPorts = [ 22 ];
      };

      users.users.root.openssh.authorizedKeys.keys = [
        meta.sshKey
      ];

      users.users.anish = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          meta.sshKey
        ];
      };

      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;

      system.stateVersion = "26.11";
    };
}
