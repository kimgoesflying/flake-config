{
  pkgs,
  inputs,
  config,
  ...
}:
{
  # Hardware boot loader configurations
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname mapping (Matches your target flake attribute)
  networking.hostName = "t460s";
  networking.networkmanager.enable = true;

  # Flake overlay for Niri
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  # Enable the GNOME Desktop Environment
  services.xserver.enable = true;
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = true;

  # Enable Tuigreet TUI Login Manager with Session Scanning
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # sessions scans the standard folders for both GNOME and Niri .desktop profiles
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions";
        user = "greeter";
      };
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  # Make all Linux virtual console text significantly larger
  console = {
    enable = true;
    font = "ter-v32n";
    packages = [ pkgs.terminus_font ];
    keyMap = "us";
  };

  # Smooth systemd configuration for fluid terminal login transitions
  systemd.services.greetd.serviceConfig = {
    Type = pkgs.lib.mkForce "simple";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Enable the Latest Niri compositor module from the flake
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;

  services.displayManager.sessionPackages = [ pkgs.niri ];
  environment.systemPackages = [
    pkgs.niri
    pkgs.kitty
  ];

  programs.dms-shell = {
    enable = true;
    enableDynamicTheming = true; # Automatically shifts system UI accents to match your wallpaper
    systemd = {
      enable = true;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    variant = ",";
    options = "grp:win_space_toggle";
  };

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

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

  # ThinkPad Power Management (Improves battery life significantly)
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      # Принудительно заставляем TLP определять режим по источнику, а не по факту заряда
      TLP_DEFAULT_MODE = "AC";
      TLP_PERSISTENT_DEFAULT = 0;

      # Настройки процессора (Убираем powersave для плавности анимаций)
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "balanced";

      # Настройка энергетической политики Intel (EPP)
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";

      # Ваши пороги батареи (оставляем для здоровья аккумулятора)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;
    };
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
  programs.firefox = {
    enable = true;
    env = {
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  programs.amnezia-vpn.enable = true;
  services.libinput.enable = true;

  # Initial system installation profile reference
  system.stateVersion = "26.05";
}
