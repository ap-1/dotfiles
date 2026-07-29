# Gaming

mocha runs Steam, Lutris, and Heroic on Hyprland with gamescope, gamemode, and MangoHud. cortado streams the desktop over the tailnet via Moonlight.

## Kernel

mocha runs a [CachyOS kernel](https://github.com/CachyOS/linux-cachyos) (see [hosts](hosts.md)) for improved frame pacing and scheduling.

## Launchers

[Steam](https://store.steampowered.com/) is enabled with remote play, dedicated server, and local network game transfer firewall rules open. [Proton-GE](https://github.com/GloriousEggroll/proton-ge-custom) is added as an extra compatibility tool. [Heroic Games Launcher](https://heroicgameslauncher.com/) covers Epic and GOG libraries. [Lutris](https://lutris.net/) is configured with stable Wine and Proton-GE.

[Sober](https://sober.vinegarhq.org/) (Roblox) is the sole Flatpak, managed declaratively through [`nix-flatpak`](https://github.com/gmodena/nix-flatpak) with sandbox overrides for Discord rich presence and gamemode.

## Performance tooling

[Gamescope](https://github.com/ValveSoftware/gamescope) runs games inside the existing Hyprland session with realtime scheduling and Wayland passthrough. [Gamemode](https://github.com/FeralInteractive/gamemode) is enabled with a Waybar indicator. [MangoHud](https://github.com/flightlessmango/MangoHud) is session-wide but hidden by default, with a keybind to toggle the overlay and another to cycle FPS limits.

## Streaming

[Sunshine](https://github.com/LizardByte/Sunshine) streams mocha's desktop over the tailnet at `sunshine.ts.anish.land`.

[Moonlight](https://moonlight-stream.org/) is installed on all desktop hosts for connecting to mocha's Sunshine.
