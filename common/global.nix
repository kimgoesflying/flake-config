{ pkgs, ... }: {
  # Set your time zone
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Allow unfree packages globally
  nixpkgs.config.allowUnfree = true;

  # Native experimental features setup
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Nix Store Optimizations and Automatic Garbage Collection
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Map Page Up & Page Down to search command prefix history globally
  environment.etc."inputrc".text = ''
    # Map Page Up & Page Down to search command prefix history
    "\e[5~": history-search-backward
    "\e[6~": history-search-forward
  '';

  # Command not found helper
  programs.nix-index.enable = true;

  # Global packages installed on every machine
  environment.systemPackages = with pkgs; [
    git
    micro
    mc
    wl-clipboard
    fastfetch
    vscode
    nixfmt
  ];
}
