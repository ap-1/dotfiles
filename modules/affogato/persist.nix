{
  flake.modules.nixos.affogato-persist = {
    # required by preservation
    boot.initrd.systemd.enable = true;

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          "/var/log"
          "/var/lib/systemd"
          "/var/lib/tailscale"
          "/var/lib/acme"
          "/var/lib/caddy"
          "/var/lib/kanidm"
          "/var/lib/headscale"
          "/var/lib/headplane"
          "/var/lib/vaultwarden"
          "/var/lib/forgejo"
          "/var/lib/tranquil-pds"
          "/var/lib/postgresql"
          "/var/backup/postgresql"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ];
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key.pub";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key.pub";
            how = "symlink";
            configureParent = true;
          }
        ];
        users.anish = {
          directories = [
            {
              directory = ".ssh";
              mode = "0700";
            }
            "nixcfg"
          ];
          files = [
            ".zsh_history"
          ];
        };
      };
    };

    # preservation owns /etc/machine-id
    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  };
}
