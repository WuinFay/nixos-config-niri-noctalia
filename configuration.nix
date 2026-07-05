# /etc/nixos/configuration.nix
# NixOS + Niri + Noctalia — Ryzen 5 5600G / RX 7600
# Rolling release con flake (nixos-unstable)
# MIGRADO DESDE: nixos_config_sway

{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Bootloader ────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 6;
  boot.loader.systemd-boot.configurationLimit = 8;

  # Kernel latest (rolling release)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Solución al "pop" de audio ────────────────────────────────
  boot.extraModprobeConfig = ''
    options snd-hda-intel power_save=0 power_save_controller=N
  '';
  boot.kernelParams = [
    "amd_pstate=active"
  ];

  # ── Red ───────────────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.networkmanager.settings = {
    main.dns = "systemd-resolved";
    connection = {
      "ipv4.ignore-auto-dns" = "true";
      "ipv6.ignore-auto-dns" = "true";
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS    = "1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001";
      DNSSEC = "allow-downgrade";
      Domains = "~.";
    };
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [];
    profiles."Conexión cableada 1" = {
      connection = {
        id   = "Conexión cableada 1";
        type = "ethernet";
        uuid = "6c15a5b4-c675-32ef-9235-56c1d0cc10d0";
      };
      ipv4 = { method = "auto"; ignore-auto-dns = "true"; };
      ipv6 = { method = "auto"; ignore-auto-dns = "true"; };
    };
  };

  # ── Zona horaria e idioma ─────────────────────────────────────
  time.timeZone = "America/Mexico_City";
  i18n.defaultLocale = "es_MX.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };
  services.xserver.xkb = {
    layout  = "latam";
    variant = "";
  };
  console.keyMap = "la-latin1";

  # ── Usuario ───────────────────────────────────────────────────
  users.users."lonso" = {
    isNormalUser = true;
    description  = "lonso";
    extraGroups  = [ "networkmanager" "wheel" "video" "audio" "render" "openrazer" ];
    packages     = with pkgs; [];
  };

  # ── Paquetes no libres ────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  # ── CPU — microcódigo AMD ─────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;

  # ── Niri WM ───────────────────────────────────────────────────
  # El módulo niri-flake.nixosModules.niri (en flake.nix) habilita
  # el paquete Niri y configura el sistema. Solo necesitamos dconf y polkit.
  # programs.sway eliminado — reemplazado por Niri
  programs.dconf.enable  = true;
  programs.xwayland.enable = true;
  security.polkit.enable = true;
  
  # ── nix-ld — para binarios foráneos (playit.gg, etc.) ─────────
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    # JavaFX / SKlauncher
    gtk3
    glib
    pango
    cairo
    gdk-pixbuf
    atk
    libx11      # antes: xorg.libX11
    libxtst     # antes: xorg.libXtst
    icu        # ← para tModLoader
    openssl    # ← para tModLoader
  ];

  # ── Nautilus — abrir terminal con clic derecho ────────────────
  programs.nautilus-open-any-terminal = {
    enable   = true;
    terminal = "sakura";
  };

  # ── XDG Portals ───────────────────────────────────────────────
  # Niri implementa el portal ScreenCast de forma nativa (a diferencia
  # de Sway que necesitaba xdg-desktop-portal-wlr).
  # niri-flake.nixosModules.niri ya configura el portal de screenshare.
  # Aquí solo declaramos el portal GTK para selectores de archivos y diálogos.
xdg.portal = {
  enable       = true;
  extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-gnome   # ← agrega esto
  ];
  config.common = {
    default = [ "gtk" ];
    "org.freedesktop.impl.portal.ScreenCast"    = [ "gnome" ];
    "org.freedesktop.impl.portal.Screenshot"    = [ "gnome" ];
    "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
  };
};

  # ── Gestor de sesión — greetd + tuigreet ─────────────────────
  # CAMBIO: --cmd sway → --cmd niri
services.greetd = {
  enable = true;
  settings = {
    default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'niri --session'";
      user    = "greeter";
    };
  };
};

  # ── AMD GPU — drivers 64 + 32 bit ────────────────────────────
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
    ];
  };
  hardware.amdgpu.initrd.enable    = true;
  hardware.amdgpu.overdrive.enable = true;

  # ── OpenRazer ─────────────────────────────────────────────────
  hardware.openrazer.enable = true;
  hardware.openrazer.devicesOffOnScreensaver = false;

  # ── LACT — control de GPU ─────────────────────────────────────
  services.lact.enable = true;

  # ── GVfs + udisks2 — montaje automático USB/MTP ──────────────
  services.gvfs.enable    = true;
  services.udisks2.enable = true;

  # ── PipeWire ──────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # ── Evitar que WirePlumber suspenda los dispositivos ──────────
  services.pipewire.wireplumber.extraConfig."51-disable-suspension" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_input.*"; }
          { "node.name" = "~alsa_output.*"; }
        ];
        actions.update-props = {
          "session.suspend-timeout-seconds" = 0;
        };
      }
    ];
  };

  # ── RyzenAdj — temperatura máxima 75 °C ──────────────────────
  systemd.services.ryzenadj = {
    description = "Aplicar límites de RyzenAdj al inicio";
    wantedBy    = [ "multi-user.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart       = "${pkgs.ryzenadj}/bin/ryzenadj --tctl-temp=75";
    };
  };
  systemd.services.greetd.serviceConfig = {
  Type        = "idle";
  StandardInput  = "tty";
  StandardOutput = "tty";
  StandardError  = "journal";
  TTYReset       = true;
  TTYVHangup     = true;
  TTYVTDisallocate = true;
};
  # ── ZRAM ──────────────────────────────────────────────────────
  zramSwap = {
    enable        = true;
    algorithm     = "zstd";
    memoryPercent = 25;
    priority      = 100;
  };

  # ── TRIM semanal para SSD ─────────────────────────────────────
  # Declarado explícitamente — el default de NixOS es false
  services.fstrim.enable = true;

  # ── Flatpak ───────────────────────────────────────────────────
  services.flatpak.enable = true;

  # ── SVG en selectores de archivo ─────────────────────────────
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # ── Journald ──────────────────────────────────────────────────
  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  # ── Variables de sesión ───────────────────────────────────────
  environment.sessionVariables = {
    # GPU / Wine
    XDG_CURRENT_DESKTOP = "gnome:niri";  # ← cambia el "niri" actual por esto
    WINEESYNC                          = "1";
    WINEFSYNC                          = "1";
    RADV_PERFTEST                      = "gpl";
    mesa_glthread                      = "true";
    MESA_SHADER_CACHE_MAX_SIZE         = "1G";
    NIXOS_OZONE_WL                     = "1";
    #Wayland / backends
    #XDG_CURRENT_DESKTOP                = "niri";
    GDK_BACKEND                        = "wayland";
    QT_QPA_PLATFORM                    = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER                    = "wayland,x11";
    MOZ_ENABLE_WAYLAND                 = "1";
    ELECTRON_OZONE_PLATFORM_HINT       = "wayland";
  };

  environment.variables = {
    XCURSOR_THEME = "breeze_cursors";
    XCURSOR_SIZE  = "24";
  };

  # ── Sudo sin contraseña para perfil-cpu ──────────────────────
  security.sudo.extraRules = [
    {
      users = [ "lonso" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/perfil-cpu";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ── Coredumps deshabilitados ──────────────────────────────────
  systemd.coredump.enable = false;

  # ── Steam, Gamemode, Gamescope ────────────────────────────────
  programs.steam.enable    = true;
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  # Módulo niri-flake — instala portal file, D-Bus service y ScreenCast
  programs.niri.enable = true;

  # ── Nix store — optimización y GC ────────────────────────────
  nix = {
    settings = {
      auto-optimise-store   = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 7d";
    };
  };

  # ── Fuentes ───────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    inter
    font-awesome_6
    nerd-fonts.mononoki
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # ── Paquetes del sistema ──────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Hardware / periféricos
    openrazer-daemon
    polychromatic
    #niri
    pkgs.xwayland-satellite
    xorg.libXcursor
    xorg.libX11
    xcursor-themes
    librewolf
    # Terminal / shell
    sakura micro fastfetch htop config.boot.kernelPackages.cpupower

    # Íconos y temas GTK
    adwaita-icon-theme
    hicolor-icon-theme
    gsettings-desktop-schemas
    gnome-themes-extra
    kdePackages.breeze
    nautilus-python

    # Wayland — herramientas que Noctalia NO reemplaza
    grim                  # capturas de pantalla (necesario para screenshot-niri.sh)
    slurp                 # selección de área
    wl-clipboard          # clipboard
    wf-recorder           # grabación de pantalla
    cliphist              # historial de portapapeles
    jq                    # NUEVO: parsear JSON de `niri msg` en scripts
    lxqt.lxqt-policykit  # agente Polkit

    # ELIMINADOS vs config Sway (Noctalia los reemplaza):
    # waybar wlogout rofi swaybg wlsunset swayosd nwg-look

    # Audio
    pavucontrol brightnessctl playerctl

    # Multimedia
    mpv yt-dlp ffmpeg shotcut
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

    # Apps de escritorio
    nautilus baobab loupe qbittorrent kooha chromium
    vesktop gnome-text-editor file-roller obsidian

    # Ofimática
    libreoffice

    # Red
    networkmanagerapplet

    # GPU / sistema
    vulkan-tools radeontop amdgpu_top ryzenadj

    # Archivos / compresión
    exfatprogs ntfs3g p7zip unrar

    # Juegos / Wine
    jdk21
    wineWow64Packages.staging
    protonup-qt

    # Utilidades
    git curl wget unzip tree

    # Script de perfil de CPU (sin contraseña via sudo)
    (writeShellApplication {
      name          = "perfil-cpu";
      runtimeInputs = [ bash coreutils gawk config.boot.kernelPackages.cpupower ];
      text          = builtins.readFile ./scripts/perfil-cpu.sh;
    })
  ];

  system.stateVersion = "26.05";
}
