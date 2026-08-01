{ config, inputs, ... }:
let
  meta = config.flake.meta;
in
{
  flake.modules.homeManager.shell =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];

      home.packages = with pkgs; [
        license-go
        microfetch
        tree
        sesh
        fzf
        mosh
        (writeShellScriptBin "dev" (builtins.readFile ./dev.sh))
        (writeShellScriptBin "dev-run" (builtins.readFile ./dev-run.sh))
      ];

      programs.devenv = {
        enable = true;
        enableZshIntegration = true;
      };

      # enabled manually for catppuccin
      programs.bat.enable = true;
      programs.fzf = {
        enable = true;
        enableZshIntegration = false;
      };
      programs.tmux = {
        enable = true;
        mouse = true;
        historyLimit = 50000;
        extraConfig = ''
          set -g set-clipboard on
          set -as terminal-features ',*:clipboard'
        '';
      };

      programs.eza = {
        enable = true;
        git = true;
        icons = "auto";
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        dotDir = "${config.xdg.configHome}/zsh";

        shellAliases = {
          cat = "bat --style=plain --paging=never";
          update = if pkgs.stdenv.isDarwin then "nh darwin switch ~/nixcfg" else "nh os switch ~/nixcfg";
        };

        initContent = lib.mkMerge [
          (lib.mkBefore ''
            gh_token=$(${lib.getExe pkgs.gh} auth token 2>/dev/null)
            [ -n "$gh_token" ] && export NIX_CONFIG="access-tokens = github.com=$gh_token"
            unset gh_token
          '')
          ''
            microfetch
          ''
        ];
      };

      programs.pay-respects = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.nix-index = {
        enable = true;
        # pay-respects owns command_not_found_handler
        enableZshIntegration = false;
      };
      programs.nix-index-database.comma.enable = true;

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [ "--cmd cd" ];
      };

      programs.atuin = {
        enable = true;
        enableZshIntegration = true;
        settings.sync_address = "http://affogato.${meta.tailnetDomain}:8888";
      };
    };
}
