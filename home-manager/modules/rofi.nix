{ config, pkgs, lib, ... }:

let
  rofiConfigDir = ../../share/dotfiles/.config/rofi; # Adjust as needed
  # The config.rasi includes paths like:
  # @import "~/.config/ml4w/settings/rofi-font.rasi"
  # @theme "~/.config/rofi/colors.rasi" (this will be fine as we link colors.rasi)
  # @import "~/.cache/ml4w/hyprland-dotfiles/current_wallpaper.rasi"
  # These external files (ml4w settings, cache files) need to be present at those exact paths.
  # We will assume they are managed by other modules/scripts or generated at runtime.
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland; # Or pkgs.rofi if not on Wayland / prefer X11 version

    # Rofi configuration can be complex to translate directly into Nix attributes.
    # Linking the existing .rasi files is usually the most straightforward approach.
    # The `extraConfig` option in home-manager's rofi module is for appending text,
    # not for setting the main config file path in a way that resolves its internal @import or @theme.

    # We will link the entire rofi configuration directory.
    # Rofi typically looks for `config.rasi` in `~/.config/rofi/`.
  };

  # Link the main Rofi configuration file
  home.file.".config/rofi/config.rasi" = {
    source = rofiConfigDir + "/config.rasi";
  };

  # Link other .rasi files that are typically co-located or imported by config.rasi
  # or used for specific rofi modes/scripts.
  home.file.".config/rofi/colors.rasi" = {
    source = rofiConfigDir + "/colors.rasi";
  };
  home.file.".config/rofi/config-cliphist.rasi" = {
    source = rofiConfigDir + "/config-cliphist.rasi";
  };
  home.file.".config/rofi/config-compact.rasi" = {
    source = rofiConfigDir + "/config-compact.rasi";
  };
  home.file.".config/rofi/config-hyprshade.rasi" = {
    source = rofiConfigDir + "/config-hyprshade.rasi";
  };
  home.file.".config/rofi/config-old.rasi" = {
    source = rofiConfigDir + "/config-old.rasi";
  };
  home.file.".config/rofi/config-screenshot.rasi" = {
    source = rofiConfigDir + "/config-screenshot.rasi";
  };
  home.file.".config/rofi/config-short.rasi" = {
    source = rofiConfigDir + "/config-short.rasi";
  };
  home.file.".config/rofi/config-themes.rasi" = {
    source = rofiConfigDir + "/config-themes.rasi";
  };

  # If there are any scripts or other assets in rofiConfigDir (e.g., a 'scripts' subdirectory)
  # that rofi or its themes/modes depend on, they should also be linked.
  # The `ls` output didn't show a 'scripts' subfolder directly under rofi, but be mindful if themes use them.
  # Example:
  # home.file.".config/rofi/scripts" = {
  #   source = rofiConfigDir + "/scripts";
  #   recursive = true;
  #   executable = true; # Not a valid option for recursive linking, handle per script or use other methods
  # };

  # Add packages that Rofi might need, or that its modes/scripts might call.
  home.packages = with pkgs; [
    rofi-wayland # Or rofi
    # Add dependencies for Rofi modi or scripts if any:
    # e.g., for filebrowser: findutils or similar
    # e.g., for window switcher: wmctrl (X11) or equivalent for Wayland if external
    # e.g., cliphist for config-cliphist.rasi
    (pkgs.callPackage (fetchgit {
      url = "https://github.com/sentriz/cliphist";
      rev = "v0.4.0"; # use latest commit or tag
      sha256 = "0k5w7g0wh9jgmq532w3w6z7n3x66m0ji207sgjwn7c11z8x30x6y"; # Check for correct sha256
    }) { }) # Example for cliphist if not in nixpkgs or if you need a specific version
    # hyprshade for config-hyprshade.rasi (if it's a package)
  ];

  # Notes on external includes in config.rasi:
  # 1. `@import "~/.config/ml4w/settings/rofi-font.rasi"`:
  #    This file must exist at this path. It should be managed by another Nix module
  #    if it's part of your dotfiles (e.g., in `share/dotfiles/.config/ml4w/settings/`).
  # 2. `@import "~/.cache/ml4w/hyprland-dotfiles/current_wallpaper.rasi"`:
  #    This implies some script generates this file in the cache. Home Manager won't
  #    manage cache files directly. Ensure the script that creates it works correctly.

  # If you wanted to use Rofi's theming capabilities via home-manager options:
  # programs.rofi.theme = "path/to/your/theme.rasi";
  # Or
  # programs.rofi.theme = {
  #   "*" = {
  #     primary = "#FF0000";
  #     // ... other theme elements
  #   };
  #   "element-text" = {
  #     background-color = "transparent";
  #     text-color = "inherit";
  #   };
  # };
  # But since you have a full config.rasi, linking is more appropriate.
}
