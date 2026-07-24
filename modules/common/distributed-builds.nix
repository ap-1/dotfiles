{ config, ... }:
let
  hosts = config.flake.hosts;

  builderSsh = ''
    Host cortado
      HostName ${hosts.cortado.tailnet.ipv4}
      User anish
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null

    Host mocha
      HostName ${hosts.mocha.tailnet.ipv4}
      User anish
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null
  '';
in
{
  flake.modules.nixos.distributed-builds = {
    nix.distributedBuilds = true;
    nix.settings.builders-use-substitutes = true;
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];

    nix.buildMachines = [
      {
        hostName = "cortado";
        sshUser = "anish";
        systems = [ "aarch64-darwin" ];
        protocol = "ssh-ng";
        maxJobs = 8;
        speedFactor = 2;
        supportedFeatures = [ "big-parallel" ];
      }
    ];

    programs.ssh.extraConfig = builderSsh;
  };

  flake.modules.darwin.distributed-builds = {
    nix.distributedBuilds = true;
    nix.settings.builders-use-substitutes = true;
    nix.settings.trusted-users = [
      "root"
      "@admin"
    ];

    nix.buildMachines = [
      {
        hostName = "mocha";
        sshUser = "anish";
        systems = [ "x86_64-linux" ];
        protocol = "ssh-ng";
        maxJobs = 12;
        speedFactor = 2;
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
    ];

    environment.etc."ssh/ssh_config.d/100-nix-builders.conf".text = builderSsh;
  };
}
