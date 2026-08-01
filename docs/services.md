# Services

All three exposure surfaces come from the `flake.services` registry:

```nix
flake.services = {
  public.headscale = "reverse_proxy http://127.0.0.1:8080";  # caddy site block
  tunnel.git = "http://127.0.0.1:3001";                      # cloudflared ingress url
  tailnet.pdf = "mocha";                                     # alias -> host
};
```

A `services.public` entry maps a name to the Caddy site block that fronts it, served at `<name>.anish.land` with a per-name ACME certificate and direct `A`/`AAAA` DNS records. A `services.tunnel` entry maps a name to the localhost URL that cloudflared proxies to, served at `<name>.anish.land` through a Cloudflare Tunnel with `CNAME` DNS records. A `services.tailnet` entry maps a name to the host that serves it, and the name becomes a headscale DNS record at `<name>.ts.anish.land`.

## Reverse proxy and certificates

Hosts that expose services through Caddy import a shared proxy module that turns a set of named Caddy site blocks into virtual hosts and provisions the ACME certificates they use. Certificates are issued over the Cloudflare DNS-01 challenge, which requires the Cloudflare API token as a [secret](secrets.md).

affogato uses Caddy only for `services.public`, issuing a per-name certificate and opening ports 80 and 443. A tailnet host such as mocha sets its domain to `ts.anish.land`, issues a single `*.ts.anish.land` wildcard certificate, and opens port 443 only on the `tailscale0` interface.

## Tunnel service

Most public services on affogato are served through a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/), which hides affogato's IP and requires no inbound ports. cloudflared makes an outbound connection to Cloudflare's edge and proxies incoming requests to each service's localhost port. A tunnel service comprises:

- an entry in `services.tunnel.<name>` whose value is the localhost URL;
- a matching `<name>` in the OpenTofu Cloudflare `tunnel_subdomains` list, applied with `tofu apply`, which publishes a `CNAME` record pointing the name at the tunnel;
- a module binding the app to its local port, imported by affogato's role.

kanidm's HTTPS origin has TLS verification disabled since it uses an internal certificate.

headscale cannot go through a Cloudflare Tunnel because it uses custom HTTP upgrade headers (`tailscale-control-protocol`, `derp`) that cloudflared does not support, and the PDS cannot because relays hold long-lived firehose websockets against it and blobs exceed the request body limit a tunnel allows.

## Direct public service

A direct public service is fronted by Caddy with its own ACME certificate and direct DNS records:

- an entry in `services.public.<name>` whose value is its Caddy site block;
- a matching `<name>` in the OpenTofu Cloudflare `subdomains` list, which publishes `A` and `AAAA` records pointing at affogato;
- a module binding the app to its local port, imported by affogato's role.

A stateful service additionally has its state directory in affogato's [preservation set](architecture.md#persistence).

## Tailnet service

A tailnet service is served by its host's own Caddy at `<name>.ts.anish.land` and is reachable only over the mesh. Its module binds the app to a loopback port and registers the Caddy site block that proxies to it, so the wildcard certificate covers it without further configuration. The `services.tailnet.<name> = "<host>"` entry names the host that serves it, which generates the matching MagicDNS record.

## OIDC

A service gated by [kanidm](https://kanidm.com/) has a client in the kanidm `oauth2` attrset. An entry sets its display name, subdomain, and access group, together with either a callback path or an explicit list of redirect origins, and a tailnet client also names its domain. The client, its access group, the secret declaration, and `anish`'s membership are generated from the entry. The client secret lives in a [secret](secrets.md), and the app authenticates against `https://idp.anish.land/oauth2/openid/<name>`.
