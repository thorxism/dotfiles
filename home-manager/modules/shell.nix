{ config, pkgs, lib, ... }:

let
  dotfilesDir = ../../share/dotfiles; # Adjust as needed
  bashConfigDir = dotfilesDir + "/.config/bashrc";
  zshConfigDir = dotfilesDir + "/.config/zshrc";
in
{
  programs.bash = {
    enable = true;
    # The existing .bashrc acts as a loader for files in ~/.config/bashrc/
    # We will replicate this structure.
    # home-manager will symlink .bashrc from the store.
    # The loader script in .bashrc will then source files from ~/.config/bashrc/
    # which we will also populate using home.file.

    # Link the main .bashrc loader script
    bashrcTrusted = true; # Allow sourcing files from .bashrc
    # source .bashrc directly in home.file instead of programs.bash.shellAliases, etc.
    # programs.bash.bashrcExtra = builtins.readFile (dotfilesDir + "/.bashrc"); # This would append, not replace.

    # It's better to let home-manager create its own .bashrc and then source our custom loader.
    # Or, if the .bashrc is mostly just the loader, we can put the loader logic into initExtra.
    # However, the existing .bashrc is simple enough to be linked if we ensure the paths it uses are correct.
    # Let's try linking the .bashrc and the .config/bashrc/* files.
  };

  home.file.".bashrc" = {
    source = dotfilesDir + "/.bashrc";
  };

  # Link the contents of share/dotfiles/.config/bashrc/ to ~/.config/bashrc/
  # home.file.".config/bashrc" = {
  #   source = bashConfigDir;
  #   recursive = true;
  # };
  # More granularly:
  home.file.".config/bashrc/00-init" = { source = bashConfigDir + "/00-init"; };
  home.file.".config/bashrc/10-aliases" = { source = bashConfigDir + "/10-aliases"; };
  home.file.".config/bashrc/20-customization" = { source = bashConfigDir + "/20-customization"; };
  home.file.".config/bashrc/30-autostart" = { source = bashConfigDir + "/30-autostart"; };
  # This setup means that the user's `~/.config/bashrc/custom/` directory for overrides will work as expected.

  programs.zsh = {
    enable = true;
    # Similar to bash, the .zshrc is a loader.
    # Link .zshrc and the contents of .config/zshrc/
    # programs.zsh.initExtra = builtins.readFile (dotfilesDir + "/.zshrc"); # This would append.

    # Home Manager's zsh module has better integration for managing .zshenv, .zprofile, .zshrc, .zlogin.
    # It typically generates its own .zshrc and sources various snippets.
    # To use the existing loader structure:
    # 1. Link .zshrc using home.file.
    # 2. Link contents of .config/zshrc/ using home.file.
    # This bypasses some of home-manager's direct zsh config features but preserves the existing setup.
    # Make sure this doesn't conflict with other zsh settings managed by home-manager.
    # For a pure "link my existing config" approach, this is viable.

    # If you want to use oh-my-zsh or plugins via home-manager, this approach might need reconsideration.
    # The current .zshrc doesn't show oh-my-zsh, so direct linking should be fine.
    dotDir = ".config/zsh"; # Specifies where to look for .zshrc, .zshenv etc. if not in HOME
                            # This is not what we want here. We want to place .zshrc in $HOME.
  };

  home.file.".zshrc" = {
    source = dotfilesDir + "/.zshrc";
  };

  # Link the contents of share/dotfiles/.config/zshrc/ to ~/.config/zshrc/
  # home.file.".config/zshrc" = {
  #   source = zshConfigDir;
  #   recursive = true;
  # };
  # More granularly:
  home.file.".config/zshrc/00-init" = { source = zshConfigDir + "/00-init"; };
  home.file.".config/zshrc/20-customization" = { source = zshConfigDir + "/20-customization"; };
  home.file.".config/zshrc/25-aliases" = { source = zshConfigDir + "/25-aliases"; };
  home.file.".config/zshrc/30-autostart" = { source = zshConfigDir + "/30-autostart"; };
  # This allows the `~/.config/zshrc/custom/` directory to work as intended by the loader.


  # Common shell packages
  home.packages = with pkgs; [
    bash # Ensure bash is available
    zsh  # Ensure zsh is available
    # Add common shell utilities if not already present or managed by other modules
    # e.g., coreutils, findutils, grep, sed, awk, util-linux
    # fastfetch (if it's used by shell configs, not visible in .bashrc/.zshrc directly but common)
  ];

  # If you want to set zsh as the default shell:
  # users.defaultUserShell = pkgs.zsh; # This is a NixOS system configuration, not home-manager.
  # For home-manager, you might set it in `programs.zsh` if the option exists, or ensure it's set manually.
  # programs.zsh.defaultShell = true; # This is not a standard HM option.
  # Typically, you run `chsh -s $(which zsh)` manually or via a NixOS config.
}
