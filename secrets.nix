let
  meta = (import ./modules/data/meta.nix).flake.meta;
  hosts = (import ./modules/data/hosts.nix).flake.hosts;

  anish = meta.sshKey;

  cortado = hosts.cortado.sshKey;
  mocha = hosts.mocha.sshKey;
  affogato = hosts.affogato.sshKey;

  all = [
    anish
    cortado
    mocha
    affogato
  ];
in
{
  "secrets/vaultwarden.age".publicKeys = all;
  "secrets/stash-jwt.age".publicKeys = all;
  "secrets/stash-session.age".publicKeys = all;
  "secrets/stash-password.age".publicKeys = all;
  "secrets/opentofu.age".publicKeys = [ anish ];
  "secrets/affogato-password.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/cloudflare-dns.age".publicKeys = [
    anish
    affogato
    mocha
  ];
  "secrets/cloudflared-tunnel.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/kanidm-admin.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/kanidm-idm-admin.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/kanidm-oauth2-headscale.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/kanidm-oauth2-headplane.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/headplane-cookie-secret.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/headscale-api-key.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/kanidm-oauth2-vaultwarden.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/headscale-authkey-mocha.age".publicKeys = [
    anish
    mocha
  ];
  "secrets/headscale-authkey-affogato.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/headscale-authkey-cortado.age".publicKeys = [
    anish
    cortado
  ];
  "secrets/kanidm-oauth2-forgejo.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/kanidm-oauth2-immich.age".publicKeys = [
    anish
    affogato
    mocha
  ];
  "secrets/kanidm-oauth2-open-webui.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/open-webui-oauth.age".publicKeys = [
    anish
    mocha
  ];
  "secrets/kanidm-oauth2-litellm.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/litellm-env.age".publicKeys = [
    anish
    mocha
  ];
  "secrets/cliproxyapi-api-key.age".publicKeys = [
    anish
    mocha
  ];
  "secrets/cliproxyapi-management.age".publicKeys = [
    anish
    mocha
  ];
  "secrets/hindsight-env.age".publicKeys = [
    anish
    mocha
  ];
  "secrets/kanidm-oauth2-pds.age".publicKeys = [
    anish
    affogato
  ];
  "secrets/tranquil-pds-env.age".publicKeys = [
    anish
    affogato
  ];
}
