{ config, pkgs, lib, ... }:

let
  kittyConfigDir = ../../share/dotfiles/.config/kitty; # Adjust as needed
  # The kitty.conf includes $HOME/.config/ml4w/settings/kitty-cursor-trail.conf
  # This path will be relative to the user's actual home when kitty runs.
  # We need to ensure that file is also managed by Home Manager if it's part of the dotfiles repo.
  # For now, we assume it will be placed correctly by another module or it exists.
  # If `ml4w` is another set of dotfiles you want to manage, it should also be linked.
  # Let's check if `share/dotfiles/.config/ml4w/settings/kitty-cursor-trail.conf` exists.
  # If not, this include might fail unless that file is created by some script managed by this repo.

  # The include ./custom.conf is relative to ~/.config/kitty/custom.conf
  # Users can create this file themselves if they want to override settings.
in
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    # Option 1: Link the main kitty.conf and let it include others.
    # This is often the easiest for existing complex configurations.
    # configFile = kittyConfigDir + "/kitty.conf"; # This would make HM copy it to the Nix store and link.
    # However, kitty.conf uses relative includes like `include colors-wallust.conf`
    # which expect those files to be in the same directory as kitty.conf (i.e., ~/.config/kitty/).
    # So, we need to link the individual files into ~/.config/kitty/.

    # Option 2: Define settings directly in Nix.
    # This is cleaner if you want full Nix control but requires translating the config.
    # settings = {
    #   font_family = "JetBrainsMono Nerd Font";
    #   font_size = 12;
    #   background_opacity = "0.7"; # Note: numbers might need to be strings for some kitty options
    #   enable_audio_bell = false;
    #   window_padding_width = 10;
    #   hide_window_decorations = "yes"; # Or true if it accepts boolean
    #   "confirm_os_window_close" = 0; # Quotes for options with special characters or that look like paths
    #   # ... and so on for all options
    #   # For includes, it's trickier. You might need to use `extraConfig` or manually concatenate.
    # };

    # Option 3: Use `extraConfig` to append the content of kitty.conf.
    # This is good if you want to set some base settings via Nix and append the rest.
    # extraConfig = builtins.readFile (kittyConfigDir + "/kitty.conf");
    # This also has issues with relative includes if not all files are in the store path kitty is configured with.

    # Best approach for this existing setup: Link all necessary files.
  };

  # Link kitty.conf
  home.file.".config/kitty/kitty.conf" = {
    source = kittyConfigDir + "/kitty.conf";
  };

  # Link files included by kitty.conf that are in the same directory
  home.file.".config/kitty/colors-matugen.conf" = {
    source = kittyConfigDir + "/colors-matugen.conf";
  };

  home.file.".config/kitty/colors-wallust.conf" = {
    source = kittyConfigDir + "/colors-wallust.conf";
  };

  # Regarding `include $HOME/.config/ml4w/settings/kitty-cursor-trail.conf`:
  # This file needs to be present at that exact path in the user's home directory.
  # If `ml4w` configs are part of this dotfiles repository (e.g. in `share/dotfiles/.config/ml4w`),
  # then another module (e.g., `ml4w.nix` or a general `dotfiles.nix`) should handle linking it.
  # For example, if it's at `../../share/dotfiles/.config/ml4w/settings/kitty-cursor-trail.conf`:
  # home.file.".config/ml4w/settings/kitty-cursor-trail.conf" = {
  #   source = ../../share/dotfiles/.config/ml4w/settings/kitty-cursor-trail.conf; # Adjust path
  #   # Ensure parent directories are created if not managed elsewhere
  #   # mklink will create .config/ml4w/settings if they don't exist.
  # };
  # For now, this kitty.nix module will assume that kitty-cursor-trail.conf is managed elsewhere
  # or will be created by some script. If it's crucial and part of `share/dotfiles`, we should add it.
  # Let's assume for now it's handled by a hypothetical ml4w.nix or similar.

  # The `include ./custom.conf` is for user overrides. Home Manager doesn't need to manage this file,
  # as users can create it manually in `~/.config/kitty/custom.conf`. If it were a default part of
  # the config that *should* exist, we'd link it too.

  # Add any dependencies Kitty might need, though usually it's self-contained.
  # JetBrainsMono Nerd Font should be handled by the theming/fonts module.
  home.packages = with pkgs; [
    kitty # Already specified by programs.kitty.package, but good for clarity
    # Add other explicit dependencies if any (e.g., shell integration scripts if not bundled)
  ];
}
