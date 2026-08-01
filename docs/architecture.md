# Architecture

This config follows the [dendritic pattern](https://github.com/mightyiam/dendritic). It is a [flake-parts](https://flake.parts/) flake in which every `.nix` file in the `modules/` tree is a self-contained module, recursively imported by [`import-tree`](https://github.com/vic/import-tree). A file's path names the feature it implements and has no effect on evaluation, so files are grouped into topic directories.

## Layout

- `common/` and `desktop/` hold feature modules grouped by scope. `common/` applies to every host, `desktop/` to the graphical hosts. Each defines a `flake.modules.{nixos,homeManager,darwin}.<name>`.
- `affogato/`, `mocha/` and `cortado/` hold the modules specific to one host, plus that host's `system.nix`.
- `roles/` bundle those modules under a name (`common`, `desktop`, and one per host) for a configuration to import.
- `data/` hold flake-level data registries, read elsewhere via `config.flake.*`.

## Composition

`flake.nix` calls `mkFlake` with two imports. `flake-parts.flakeModules.modules` provides the `flake.modules.<class>.<name>` option, and `import-tree ./modules` pulls every module file into that single evaluation. Each file then contributes one part of the flake:

- feature modules and roles populate `flake.modules.{nixos,homeManager,darwin}`; a role is a module whose `imports` reference other modules as `config.flake.modules.<class>.<name>`.
- data files set `flake.{meta,hosts,services}`, readable from any module through `config.flake.*`.
- a host's `system.nix` calls `nixosSystem` or `darwinSystem` to build its `flake.{nixos,darwin}Configurations.<host>` output from the bundles it needs (its host role, `common`, and `desktop` on graphical hosts) plus flake inputs such as agenix and home-manager.

## Hosts

- `affogato` is the public NixOS VPS, running services behind cloudflared and Caddy.
- `mocha` is the NixOS desktop.
- `cortado` is the nix-darwin laptop.

All three join the self-hosted [tailnet](networking.md). Per-host hardware is in [hosts](hosts.md).

Every host imports [srvos](https://github.com/nix-community/srvos) base modules: `server` and `hardware-hetzner-cloud` on affogato, `desktop` on mocha and cortado. The common role adds the `mixins-terminfo` and `mixins-trusted-nix-caches` mixins on all hosts.

## Exposure

Services are reached one of three ways:

- Most public services on affogato go through a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) at `<name>.anish.land`, proxied by cloudflared to their localhost port. affogato's IP is not exposed for these services.
- headscale, the PDS and the knot resolve directly through Cloudflare DNS to affogato and are served by Caddy, since none of them works behind a Cloudflare Tunnel.
- Tailnet services resolve through the mesh's MagicDNS to their host at `<name>.ts.anish.land` and are served by that host's Caddy under one `*.ts.anish.land` ACME certificate.

Caddy certificates are issued over the Cloudflare DNS-01 challenge, and OIDC-gated services authenticate against [kanidm](https://kanidm.com/). See [services](services.md) for the registry that drives all three.

## Persistence

affogato's root filesystem is a tmpfs, recreated empty on every boot; only the `/nix` and `/persist` btrfs subvolumes survive. State is carried across reboots by the [preservation](https://github.com/nix-community/preservation) module, which restores a fixed set of paths from `/persist`. These cover service state under `/var/lib`, the nightly database dumps, systemd and nixos state, machine identity (`/etc/machine-id` and the SSH host keys), logs, and the `anish` home. Anything outside that set does not survive a reboot. mocha and cortado use ordinary persistent root filesystems.

## Databases

Applications that need PostgreSQL share one local instance per host, each declaring its database through a shared module that provisions the database and its role. Every database is dumped nightly.

## Binary caches

The NixOS hosts route all substitution through [ncro](https://github.com/feel-co/ncro) (shared `ncro` module), a local cache optimizer on `localhost:5000` forced as the sole substituter. Its upstreams and their signing keys are defined in that module; cortado (darwin) uses direct substituters.

## Deploying

Each host is built locally with `nh os switch ~/nixcfg` (aliased to `update`).
