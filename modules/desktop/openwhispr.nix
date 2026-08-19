{ inputs, ... }:
{
  flake.modules.nixos.openwhispr = {
    # also enables ydotoold, uinput, group membership
    imports = [ inputs.openwhispr.nixosModules.default ];
    programs.openwhispr = {
      enable = true;
      users = [ "anish" ];
    };
  };
}
