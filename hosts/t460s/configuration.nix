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

  # Настройка Greetd + Tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "greeter";
        command =
          let
            sessionDirs = [
              "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
              "${config.services.displayManager.sessionData.desktops}/share/xsessions"
            ];
            sessionsPath = pkgs.lib.makeSearchPath "" sessionDirs;
          in
          # --cmd niri-session указывается как fallback без абсолютного пути, так как tuigreet запустит его через сессию пользователя после авторизации
          "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions '${sessionsPath}' --cmd niri-session";
      };
    };
  };

  systemd.services.greetd.serviceConfig.Type = pkgs.lib.mkForce "simple";
  systemd.services.greetd.serviceConfig.StandardInput = "tty";
  systemd.services.greetd.serviceConfig.StandardOutput = "tty";
  systemd.services.greetd.serviceConfig.StandardError = "journal";
  systemd.services.greetd.serviceConfig.TTYReset = true;
  systemd.services.greetd.serviceConfig.TTYVHangup = true;
  systemd.services.greetd.serviceConfig.TTYVTDisallocate = true;

  security.pam.services.greetd.enableGnomeKeyring = true;

  # Make all Linux virtual console text significantly larger
  console = {
    enable = true;
    font = "ter-v32n";
    packages = [ pkgs.terminus_font ];
    keyMap = "us";
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
    enableDynamicTheming = true;
    systemd = {
      enable = false;
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
      TLP_DEFAULT_MODE = "AC";
      TLP_PERSISTENT_DEFAULT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "balanced";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";
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
  programs.firefox.enable = true;
  programs.amnezia-vpn.enable = true;
  services.libinput.enable = true;

  # Заставляем Firefox и другие приложения нативно работать в Wayland
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Initial system installation profile reference
  system.stateVersion = "26.05";
}
