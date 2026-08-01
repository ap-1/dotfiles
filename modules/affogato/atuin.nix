{
  flake.modules.nixos.affogato-atuin = {
    services.atuin = {
      enable = true;
      host = "0.0.0.0";
      port = 8888;
      openRegistration = true;
      database.createLocally = true;
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8888 ];
  };
}
