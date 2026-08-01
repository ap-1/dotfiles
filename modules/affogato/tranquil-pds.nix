{ config, ... }:
let
  meta = config.flake.meta;

  hostname = "pds.${meta.domain}";
in
{
  flake.modules.nixos.affogato-tranquil-pds = { config, ... }: {
    age.secrets.tranquil-pds-env.file = ../../secrets/tranquil-pds-env.age;

    services.tranquil-pds = {
      enable = true;
      database.createLocally = true;

      # JWT_SECRET, DPOP_SECRET, MASTER_KEY, and the oauth2 client secret
      environmentFiles = [ config.age.secrets.tranquil-pds-env.path ];

      settings = {
        server = {
          inherit hostname;
          host = "127.0.0.1";
          port = 3002;
          contact_email = meta.email;

          user_handle_domains = [ meta.domain ];
          disable_account_verification_gate = true;
        };

        firehose.crawlers = [ "https://bsky.network" ];
        sso.oidc = {
          client_id = "pds";
          issuer = "${meta.idpUrl}/oauth2/openid/pds";
          display_name = "Kanidm";
        };
      };
    };
  };
}
