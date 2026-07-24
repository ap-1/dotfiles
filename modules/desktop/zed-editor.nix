{
  flake.modules.homeManager.zed-editor = { pkgs, ... }: {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      extensions = [
        "nix"
        "ini"
        "rainbow-csv"
        "just"
        "typst"
        "terraform"
        "swift"
        "svelte"
        "toml"
        "oxc"
        "nginx"
        "discord-presence"
        "git-firefly"
        "lua"
      ];
      extraPackages = with pkgs; [
        nixd
        nil
      ];
      userSettings = {
        vim_mode = true;
        base_keymap = "VSCode";
      };
    };
  };
}
