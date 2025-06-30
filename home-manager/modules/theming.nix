{ config, pkgs, lib, ... }:

let
  dotfilesConfigDir = ../../share/dotfiles/.config; # Path to .config within dotfiles
  dotfilesShareDir = ../../share; # Path to share within dotfiles (for fonts)
in
{
  # GTK Theming
  gtk = {
    enable = true;

    # Values from share/dotfiles/.config/gtk-3.0/settings.ini
    theme = {
      name = "Adwaita"; # gtk-theme-name
      package = pkgs.adwaita-gtk-theme; # Ensure the theme package is installed
    };
    iconTheme = {
      name = "Papirus-Dark"; # gtk-icon-theme-name
      package = pkgs.papirus-icon-theme; # Ensure the icon theme package is installed
    };
    font = {
      name = "Cantarell 11"; # gtk-font-name
      # package = pkgs.gnome-themes-standard; # For Cantarell, or specify another font package
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice"; # gtk-cursor-theme-name
      size = 24;
      package = pkgs.bibata-cursors; # Ensure the cursor theme package is installed
    };
    gtk3.extraConfig = {
      gtk-toolbar-style = "GTK_TOOLBAR_ICONS";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = "0";
      gtk-menu-images = "0";
      gtk-enable-event-sounds = "1";
      gtk-enable-input-feedback-sounds = "0";
      gtk-xft-antialias = "1";
      gtk-xft-hinting = "1";
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
      gtk-application-prefer-dark-theme = "1";
    };
    # For GTK4, from share/dotfiles/.config/gtk-4.0/settings.ini
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = "true"; # Note: HM uses string "1" or "0" for bools typically
                                                 # but gtk4 settings.ini uses "true"
    };
  };

  # Link gtk.css and colors.css for GTK3 and GTK4 if they exist and are used
  home.file.".config/gtk-3.0/gtk.css" = {
    source = dotfilesConfigDir + "/gtk-3.0/gtk.css";
    # text = builtins.readFile (dotfilesConfigDir + "/gtk-3.0/gtk.css");
  };
  home.file.".config/gtk-3.0/colors.css" = {
    source = dotfilesConfigDir + "/gtk-3.0/colors.css";
  };
  home.file.".config/gtk-4.0/gtk.css" = {
    source = dotfilesConfigDir + "/gtk-4.0/gtk.css";
  };
  home.file.".config/gtk-4.0/colors.css" = {
    source = dotfilesConfigDir + "/gtk-4.0/colors.css";
  };

  # Link .gtkrc-2.0 for GTK2 applications
  home.file.".gtkrc-2.0" = {
    source = dotfilesShareDir + "/dotfiles/.gtkrc-2.0"; # Path from ls output
  };

  # Qt Theming (using qt6ct)
  programs.qt6ct = {
    enable = true;
    # Home Manager's qt module can set style, icon_theme, etc.
    # We'll try to map from qt6ct.conf
    style = "Breeze"; # From qt6ct.conf: style=Breeze
    iconTheme = "breeze-dark"; # From qt6ct.conf: icon_theme=breeze-dark
    # colorScheme = "/usr/share/qt6ct/colors/darker.conf"; # This is a path, harder to manage directly
                                                          # Qt5ct/6ct usually expects these themes to be installed system-wide.
                                                          # Or you can link the qt6ct.conf directly.
  };
  # Link the qt6ct.conf directly to preserve all settings
  home.file.".config/qt6ct/qt6ct.conf" = {
    source = dotfilesConfigDir + "/qt6ct/qt6ct.conf";
  };

  # XSettings daemon for applying GTK settings to XWayland apps more reliably
  services.xsettingsd.enable = true; # Provides xsettingsd
  home.file.".config/xsettingsd/xsettingsd.conf" = {
    source = dotfilesConfigDir + "/xsettingsd/xsettingsd.conf";
  };

  # Fonts
  # Home Manager can manage fonts by linking them to ~/.local/share/fonts/
  # or by adding font packages to home.packages.
  home.fonts.fontconfig.enable = true; # Usually good to enable fontconfig integration.

  # Link custom fonts from share/fonts/
  # This creates symlinks in ~/.local/share/fonts/
  # Need to list them or use a helper to discover them.
  # For simplicity, let's link the main font directories.
  home.file.".local/share/fonts/FiraCode" = {
    source = dotfilesShareDir + "/fonts/FiraCode";
    recursive = true;
  };
  home.file.".local/share/fonts/Fira_Sans" = {
    source = dotfilesShareDir + "/fonts/Fira_Sans";
    recursive = true;
  };
  # Alternatively, using pkgs.nerdfonts for Nerd Fonts like FiraCode:
  # home.packages = [ pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; } ];
  # And for Fira Sans:
  # home.packages = [ pkgs.fira ]; (If a package 'fira' exists providing Fira Sans)

  # Link .Xresources if it's used (typically for X applications)
  home.file.".Xresources" = {
    source = dotfilesShareDir + "/dotfiles/.Xresources";
  };

  # Packages needed for theming
  home.packages = with pkgs; [
    # GTK Themes
    adwaita-gtk-theme
    papirus-icon-theme
    bibata-cursors
    # gnome-themes-extra # Contains Adwaita, Cantarell font etc. (already as adwaita-gtk-theme)
    # Breeze for Qt and GTK if you want consistency
    breeze-gtk
    breeze-icons # For breeze-dark icon theme used in qt6ct

    # Qt6 theming tool
    qt6ct
    libsForQt5.qtstyleplugin-kvantum # If using Kvantum for Qt theming (not indicated, but common)

    # Fonts (if not linking them directly or if specific package versions are preferred)
    # (nerdfonts.override { fonts = [ "FiraCode" ]; }) # Example if using Nerd Fonts package
    # fira # Example for Fira Sans package

    # XSettings daemon for Wayland
    xsettingsd
  ];
}
