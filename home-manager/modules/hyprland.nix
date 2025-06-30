{ config, pkgs, lib, ... }:

let
  # Define paths to your existing Hyprland config files
  # Assuming your dotfiles are in a directory that will be placed alongside this home-manager config
  # or you adjust the path accordingly.
  # For this example, we assume the `share` directory is at the root of the Nix flake/config.
  hyprlandConfigDir = ../../share/dotfiles/.config/hypr; # Adjust this path if your repo structure is different
in
{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland; # Or specify another package if needed
    # xwayland.enable = true; # Already enabled by default if Xwayland is found
  };

  # Home Manager packages needed for Hyprland or its scripts
  home.packages = with pkgs; [
    hyprland
    hyprpaper # For wallpaper if you use it via hyprpaper.conf
    hypridle # For idle management if you use hypridle.conf
    hyprlock # For screen locking if you use hyprlock.conf
    # Add other dependencies like rofi, waybar, dunst, etc., if they are launched by Hyprland config
    # Though it's better to manage those in their own modules.
    dbus # For dbus-update-activation-environment
    # Add any tools used in your hyprland scripts, e.g., grim, slurp, jq, etc.
    # Examples based on typical hyprland setups:
    # grim # For screenshots
    # slurp # For selecting regions for screenshots
    # wf-recorder # For screen recording
    # wlogout # For logout menu
    # swaync # Notification daemon
    # xdg-desktop-portal-hyprland # For screen sharing and other portal features
  ];

  # This is the primary way to set Hyprland's main configuration.
  # We will copy the entire directory and let hyprland.conf source other files.
  # Alternatively, you could try to translate hyprland.conf into Nix options here,
  # but that can be very complex and error-prone for large existing configs.

  # Copy the entire Hyprland configuration directory
  # Note: Home Manager will symlink these files.
  # If your scripts or Hyprland itself needs to write to these files (e.g. caching, dynamic changes),
  # this approach might need adjustment (e.g., copying them to a mutable location first).

  # home.file.".config/hypr" = {
  #   source = hyprlandConfigDir;
  #   recursive = true; # This ensures the whole directory is linked
  #   # If you need to make them executable:
  #   # executable = true; # Apply to specific script files if needed, not the whole dir.
  # };

  # A more granular approach: link individual files. This is often safer.
  # Start with the main hyprland.conf
  home.file.".config/hypr/hyprland.conf" = {
    source = ../../share/dotfiles/.config/hypr/hyprland.conf; # Adjust path
    # text = builtins.readFile (hyprlandConfigDir + "/hyprland.conf"); # Alternative if you want to embed content
  };

  # Then link other essential configuration files that hyprland.conf sources,
  # or whole directories like 'conf' or 'scripts' if they are self-contained.

  home.file.".config/hypr/colors.conf" = {
    source = hyprlandConfigDir + "/colors.conf";
  };

  home.file.".config/hypr/hypridle.conf" = {
    source = hyprlandConfigDir + "/hypridle.conf";
  };

  home.file.".config/hypr/hyprlock.conf" = {
    source = hyprlandConfigDir + "/hyprlock.conf";
  };

  home.file.".config/hypr/hyprpaper.conf" = {
    source = hyprlandConfigDir + "/hyprpaper.conf";
  };

  # Link the 'conf' directory (contains many .conf files sourced by hyprland.conf)
  home.file.".config/hypr/conf" = {
    source = hyprlandConfigDir + "/conf";
    recursive = true;
  };

  # Link the 'scripts' directory
  # You might need to make scripts executable.
  # A better way for scripts is to wrap them or add them to path via home.packages
  # or specific program options if home-manager supports it.
  # For now, we'll link them. Consider making them executable if needed.
  home.file.".config/hypr/scripts" = {
    source = hyprlandConfigDir + "/scripts";
    recursive = true;
    # If scripts need to be executable and aren't already in the source repo:
    # This is tricky with home.file as it symlinks.
    # A common pattern is to copy scripts to $HOME/.local/bin and add to PATH,
    # or use pkgs.writeShellScriptBin to make them available.
    # For simplicity, we assume scripts are executable or called with `sh scriptname`.
  };

  # Link the 'shaders' directory if you use custom shaders
  home.file.".config/hypr/shaders" = {
    source = hyprlandConfigDir + "/shaders";
    recursive = true;
  };

  # Link the 'effects' directory
  home.file.".config/hypr/effects" = {
    source = hyprlandConfigDir + "/effects";
    recursive = true;
  };

  # Environment variables specific to Hyprland session
  # Some might be set in your conf/environment.conf already.
  # If so, you might not need to duplicate them here unless you want HM to manage them.
  wayland.windowManager.hyprland.extraConfig = ''
    # Example of adding extra config directly if needed:
    # monitor=,preferred,auto,1
    # exec-once = waybar & dunst

    # The content of your hyprland.conf is complex and sources many other files.
    # The home.file approach above is generally better for such existing setups.
    # If you were starting from scratch, you might define settings here:
    # general {
    #   gaps_in = 5
    #   gaps_out = 10
    #   border_size = 2
    #   col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    #   col.inactive_border = rgba(595959aa)
    #   layout = dwindle
    # }
    # decoration {
    #   rounding = 10
    #   blur = true
    #   blur_size = 3
    #   blur_passes = 1
    #   blur_new_optimizations = on
    #   drop_shadow = yes
    #   shadow_range = 4
    #   shadow_render_power = 3
    #   col.shadow = rgba(1a1a1aee)
    # }
    # ... and so on for other sections.
  '';

  # Ensure xdg-desktop-portal-hyprland is running
  # systemd.user.services.xdg-desktop-portal-hyprland = {
  #   Unit = {
  #     Description = "xdg-desktop-portal backend for Hyprland";
  #     After = [ "graphical-session-pre.target" ]; # Adjust as needed
  #     PartOf = [ "graphical-session.target" ];    # Adjust as needed
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.xdg-desktop-portal-hyprland}/bin/xdg-desktop-portal-hyprland";
  #     Restart = "on-failure";
  #   };
  #   Install = {
  #     WantedBy = [ "graphical-session.target" ]; # Adjust as needed
  #   };
  # };
  # Simpler way if your systemd setup is standard:
  services.xdg-desktop-portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  # This might be better handled at NixOS system config level if not just for home-manager

  # If you use hyprpaper, you might configure it here or link its config
  # programs.hyprpaper = {
  #   enable = true;
  #   settings = {
  #     preload = [
  #       "~/Pictures/Wallpapers/your-wallpaper.png"
  #     ];
  #     wallpaper = ",~/Pictures/Wallpapers/your-wallpaper.png"; # monitor,path
  #     # ipc = "off"; # Or "on"
  #   };
  # };
  # Since you have hyprpaper.conf, linking it is preferred:
  # home.file.".config/hypr/hyprpaper.conf" - already done above.

  # Same for hypridle and hyprlock if they have dedicated configs managed by home-manager options.
  # programs.hypridle.enable = true; # If there's a HM option
  # programs.hyprlock.enable = true; # If there's a HM option
  # Since you have .conf files, linking them is generally the strategy.
}
