{ config, pkgs, ... }:

let
  # Path to the modules directory
  modulesPath = ./modules;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "rob";
  home.homeDirectory = "/home/rob";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Import all .nix files from the modules directory
  imports = [
    (modulesPath + "/hyprland.nix")
    (modulesPath + "/waybar.nix")
    (modulesPath + "/kitty.nix")
    (modulesPath + "/rofi.nix")
    (modulesPath + "/shell.nix")
    (modulesPath + "/theming.nix")
    # NOTE: Other application configs like nvim, swaync, nwg-dock, wlogout, etc.,
    # from the share/dotfiles/.config directory can be modularized similarly
    # if desired. For now, only the requested ones are included.
  ];

  # Nicely reload systemd units when changing GSettings schemas.
  # xsession.enable = true; # This is often useful, but can be enabled if needed.
                          # Hyprland setups might not always need this explicitly if
                          # dbus activation is handled correctly by services.

  # Basic packages can be defined here, but it's often cleaner to define
  # them within the modules that require them, or a dedicated 'packages.nix' module.
  # home.packages = [
  #   pkgs.neovim # Example package
  #   pkgs.htop     # Example package
  # ];

  # Set environment variables - can also be done in specific modules (e.g. shell.nix)
  # or a dedicated 'environment.nix' module.
  # home.sessionVariables = {
  #   EDITOR = "nvim";
  # };

  # Configure programs
  programs.home-manager.enable = true;

  # Ensure XDG directories are set up; home-manager usually handles this.
  # xdg.enable = true; # This is not a direct HM option, but related settings are under xdg.*

  # Enable user services systemd units.
  systemd.user.startServices = "sd-switch"; # Or true, "graphical-session-pre" etc.
                                          # Helps ensure services like xsettingsd start correctly.
}
}
