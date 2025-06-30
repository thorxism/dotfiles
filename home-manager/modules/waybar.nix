{ config, pkgs, lib, ... }:

let
  waybarConfigDir = ../../share/dotfiles/.config/waybar; # Adjust as needed
  # Assuming 'default' theme is what you want to use.
  # You might want to make this selectable or based on another config.
  chosenThemeDir = waybarConfigDir + "/themes/default";
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    # The 'settings' attribute expects a Nix attribute set that represents the Waybar JSON config.
    # Directly reading and parsing JSON into a Nix attrset can be complex if the JSON is not trivial
    # or uses features not easily mapped.
    # A common approach for complex JSON is to link the file.
    # However, if you want to use Nix to *generate* the JSON, you'd define it here.

    # Option 1: Link the existing config files if they are static and don't need Nix evaluation.
    # This is generally simpler for pre-existing, complex configurations.
    # Home Manager will create symlinks in ~/.config/waybar/
    # Ensure Waybar is launched to look for 'config' and 'style.css' in its default dir.

    # settings = {}; # We will link the files instead of trying to translate JSON to Nix here.
    # style = "";   # Same for style.
  };

  # Link the main 'config' file for Waybar from your chosen theme
  home.file.".config/waybar/config" = {
    source = chosenThemeDir + "/config";
    # If the config was pure JSON and you wanted to parse it (more advanced):
    # text = builtins.toJSON (builtins.fromJSON (builtins.readFile (chosenThemeDir + "/config")));
  };

  # Link the main 'style.css' file for Waybar from your chosen theme
  home.file.".config/waybar/style.css" = {
    source = chosenThemeDir + "/style.css";
  };

  # Link other files from the main waybar config directory if they are needed by scripts or Waybar itself
  home.file.".config/waybar/colors.css" = {
    source = waybarConfigDir + "/colors.css"; # This seems to be a common file
  };

  home.file.".config/waybar/launch.sh" = {
    source = waybarConfigDir + "/launch.sh";
    executable = true; # Make sure scripts are executable
  };

  home.file.".config/waybar/modules.json" = { # Some setups might use this
     source = waybarConfigDir + "/modules.json";
     # Adjust if your chosen theme has its own modules.json
     # source = chosenThemeDir + "/modules.json"; # If it exists in the theme
  };

  home.file.".config/waybar/themeswitcher.sh" = {
    source = waybarConfigDir + "/themeswitcher.sh";
    executable = true;
  };

  home.file.".config/waybar/toggle.sh" = {
    source = waybarConfigDir + "/toggle.sh";
    executable = true;
  };

  # Link the 'assets' directory used by themes
  home.file.".config/waybar/themes/assets" = {
    source = waybarConfigDir + "/themes/assets";
    recursive = true;
  };

  # If your Waybar modules execute custom scripts from within the .config/waybar directory,
  # ensure those scripts are also linked and made executable.
  # For example, if 'custom/media' in your Waybar config executes a script:
  # "exec": "$HOME/.config/waybar/mediaplayer.py"
  # You would need to link that script:
  # home.file.".config/waybar/mediaplayer.py" = {
  #   source = waybarConfigDir + "/mediaplayer.py"; # Assuming it exists at this path
  #   executable = true;
  # };
  # Looking at your config, it does use: "$HOME/.config/waybar/mediaplayer.py"
  # This script is not visible in the `ls` output of `share/dotfiles/.config/waybar/`
  # It might be in `share/dotfiles/.config/ml4w/waybar/` or similar, or missing.
  # For now, I'll assume it's managed elsewhere or needs to be added.

  # If scripts are in a subfolder of waybarConfigDir, e.g. waybarConfigDir/scripts/
  # home.file.".config/waybar/scripts" = {
  #   source = waybarConfigDir + "/scripts";
  #   recursive = true;
  #   # May need to make individual scripts executable, recursive executable is not a home.file option
  # };


  # Add any packages that your Waybar modules or scripts might need.
  home.packages = with pkgs; [
    waybar
    pavucontrol # For on-click action of pulseaudio module
    # Add other dependencies for your custom modules or scripts if any
    # e.g., playerctl for media controls, jq for JSON processing in scripts, etc.
    # From your config:
    # mpd # For the mpd module
    # upower # For battery module
    # acpi # For battery or temperature on some systems
    # networkmanagerapplet # If your network module interacts with it
  ];

  # Note on themes:
  # The current setup links the 'default' theme. If you want to easily switch themes,
  # you might need a more dynamic approach, possibly involving a script that changes
  # symlinks or a custom option in your Nix configuration to select a theme.
  # The themeswitcher.sh script you have seems to handle this outside of Nix.
  # For Nix to manage it, you'd typically define an option like:
  # options.myWaybarTheme = lib.mkOption { type = lib.types.str; default = "default"; };
  # And then use config.myWaybarTheme to select the source for config and style.css.
}
