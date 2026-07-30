{ ... }:
let
  cortadoBuilder = {
    hostName = "cortado";
    sshUser = "anish";
    systems = [ "aarch64-darwin" ];
    protocol = "ssh-ng";
    maxJobs = 8;
    speedFactor = 2;
    supportedFeatures = [ "big-parallel" ];
  };

  mochaBuilder = {
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
  };

  allBuilders = [
    cortadoBuilder
    mochaBuilder
  ];

  # offload to every builder except the host itself
  mkOffload = adminGroup: { config, ... }: {
    nix.distributedBuilds = true;
    nix.settings.builders-use-substitutes = true;
    nix.settings.trusted-users = [
      "root"
      adminGroup
    ];
    nix.buildMachines = builtins.filter (b: b.hostName != config.networking.hostName) allBuilders;
  };
in
{
  flake.modules.nixos.distributed-builds = mkOffload "@wheel";
  flake.modules.darwin.distributed-builds = mkOffload "@admin";
}
