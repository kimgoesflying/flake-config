{ pkgs, ... }: {
  # Hardware boot loader configurations
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname mapping (Matches your target flake attribute)
  networking.hostName = "t460s";
  networking.networkmanager.enable = true;

  # Enable the GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User accounts
  users.users."kim" = {
    isNormalUser = true;
    description = "Kim";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Laptop specific application wrappers
  programs.firefox.enable = true;
  programs.amnezia-vpn.enable = true;

  # Initial system installation profile reference
  system.stateVersion = "26.05";
}
