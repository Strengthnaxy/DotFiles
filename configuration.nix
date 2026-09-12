# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Detroit";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Настройка Шрифтов (Добавлен Iosevka Term Slab для терминала и системы)
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.iosevka-term-slab
    ];
  };

  # Включение графического сервера X11 и настройка i3wm
  services.xserver = {
    enable = true;
    
    # Настройка переключения раскладки клавиатуры (Alt+Shift, языки US и RU)
    xkb = {
      layout = "us,ru";
      variant = ",";
      options = "grp:alt_shift_toggle";
    };

    # Включение i3wm в качестве оконного менеджера
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu     # Стандартное меню запуска
        i3status  # Стандартная статус-панель снизу экрана
        i3lock    # Блокировщик экрана
      ];
    };
  };

  # Автоматический запуск композитора Picom (управляет прозрачностью окон и тенями)
  services.picom = {
    enable = true;
    fade = true;         # Плавное появление/исчезновение окон
    inactiveOpacity = 0.90; # Прозрачность неактивных окон (90%)
    activeOpacity = 1.0;   # Прозрачность активного окна (100%)
    vSync = true;        # Убирает разрывы экрана (тиринг)
    backend = "glx";     # Использовать видеокарту для рендеринга эффектов
  };

  # Экранный менеджер (вход в систему) SDDM
  services.displayManager.sddm = {
    enable = true;
  };

  # Включение оболочки Fish на системном уровне
  programs.fish.enable = true;

  # Включение поддержки Flatpak
  services.flatpak.enable = true;

  # Автоматическое добавление репозитория Flathub при сборке системы
  systemd.services.configure-flathub = {
    description = "Configure Flathub repository for Flatpak";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org
    '';
  };

  # Настройка Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account.
  users.users."strength" = {
    isNormalUser = true;
    description = "Strength";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.fish; # Fish по умолчанию для вашего пользователя
    packages = with pkgs; [
      # Графический софт
      telegram-desktop
      libreoffice-fresh
      kdePackages.dolphin  # Проводник Dolphin
      kitty              # Терминал

      # Инструменты кастомизации i3wm (X11)
      polybar            # Современная замена Waybar для X11
      feh                # Утилита для установки обоев рабочего стола
      picom              # Сам пакет для управления прозрачностью

      # Дополнительные утилиты для удобства в i3wm (X11)
      rofi               # Удобное и красивое меню приложений
      dunst              # Уведомления
      scrot              # Скриншоты для X11
      xclip              # Работа с буфером обмена в терминале (X11)
      networkmanagerapplet # Значок интернета в трее i3

      # Графический магазин приложений (в нем будут отображаться Flatpak пакеты)
      kdePackages.discover
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Системные пакеты и терминальные утилиты
  environment.systemPackages = with pkgs; [
    # Запрошенные утилиты
    neovim
    fastfetch
    btop
    cava
    lavat
    peaclock
    cmatrix

    # Базовые утилиты и инструменты для настройки терминала
    git
    wget
    curl
    gnumake
    unzip
    p7zip
    file
    
    # Утилиты для кастомизации Fish
    starship       # Очень красивый и быстрый prompt (тема) для Fish
  ];

  # Требуемый блок порталов для корректной работы Flatpak и графического магазина в i3wm
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  system.stateVersion = "26.05";
}
