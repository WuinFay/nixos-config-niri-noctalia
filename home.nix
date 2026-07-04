# ~/nixos-config-niri/home.nix
# Configuración de usuario vía Home Manager
# Gestiona: Niri (compositor) + Noctalia (shell) + scripts
# Se aplica automáticamente durante nixos-rebuild switch

{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    # Módulo HM de Niri — habilita programs.niri.settings
    inputs.niri-flake.homeModules.niri
    # Módulo HM de Noctalia — habilita programs.noctalia-shell
    inputs.noctalia.homeModules.default
  ];

  # ── Identidad de Home Manager ────────────────────────────────
  home.username    = "lonso";
  home.homeDirectory = "/home/lonso";
  home.stateVersion  = "26.05";
home.file.".config/niri/scripts/screenshot.sh" = {
  source = ./scripts/screenshot-niri.sh; executable = true;
};
home.file.".local/bin/cpu-profile-toggle" = {
  source = ./scripts/cpu-profile-toggle.sh; executable = true;
};
home.file.".local/bin/cpu-profile-status" = {
  source = ./scripts/cpu-profile-status.sh; executable = true;
};
  # ── Niri — compositor Wayland ─────────────────────────────────
  programs.niri.settings = {

    # ── Output ──────────────────────────────────────────────────
    outputs."HDMI-A-1" = {
      mode = { width = 1920; height = 1080; refresh = 144.0; };
      # VRR: desactivado por defecto — activar si los juegos lo soportan
      # variable-refresh-rate = true;
    };

    # ── Cursor ──────────────────────────────────────────────────
    cursor = {
      theme = "breeze_cursors";
      size  = 24;
    };

    # ── Input ───────────────────────────────────────────────────
    input = {
      keyboard = {
        xkb.layout  = "latam";
        repeat-delay = 400;
        repeat-rate  = 25;
      };
      mouse = {
        accel-profile = "flat";
        accel-speed   = 0.0;
      };
    };

    # ── Layout ──────────────────────────────────────────────────
    layout = {
      gaps = 7;
      struts = { left = 4; right = 4; top = 4; bottom = 4; };
      border = {
        enable = true;
        width  = 3;
        active.color   = "#00d4ffff"; # cian neón
        inactive.color = "#16161eff"; # fondo oscuro
      };
    };

    # ── Autostart ────────────────────────────────────────────────
    # NOTA: systemd startup está DEPRECADO en Noctalia v4.
    # Usar spawn-at-startup de Niri es el método correcto.
    spawn-at-startup = [
      # Shell unificado: barra + dock + launcher + lock + notifs
      { command = [ "noctalia-shell" ]; }
      # Agente Polkit
      { command = [ "/run/current-system/sw/bin/lxqt-policykit-agent" ]; }
      # Historial de portapapeles
      { command = [ "bash" "-c" "wl-paste --watch cliphist store" ]; }
      # Micrófono keepalive (script personal)
      { command = [ "/home/lonso/.local/bin/mic-keepalive.sh" ]; }
    ];

    # ── Prefer no CSD (Client Side Decorations) ─────────────────
    prefer-no-csd = true;

    # ── Keybinds ─────────────────────────────────────────────────
    # Equivalencias con tu config de Sway, adaptadas a Niri.
    # Niri usa columnas scrollables — Left/Right mueven entre columnas,
    # Up/Down mueven entre ventanas en la misma columna.
    binds = with inputs.niri-flake.lib.actions; {

      # ── Apps ──────────────────────────────────────────────────
      "Mod+Return".action   = spawn "sakura";
      "Mod+Shift+O".action  = spawn "obs";
      "Mod+M".action        = spawn "gnome-text-editor";
      "Mod+Q".action        = close-window;

      # ── Capturas de pantalla ──────────────────────────────────
      "Print".action       = spawn [ "/home/lonso/.config/niri/scripts/screenshot.sh" "screen" ];
      "Shift+Print".action = spawn [ "/home/lonso/.config/niri/scripts/screenshot.sh" "area" ];
      "Mod+Print".action   = spawn [ "/home/lonso/.config/niri/scripts/screenshot.sh" "active" ];

      # ── Audio ─────────────────────────────────────────────────
      "XF86AudioRaiseVolume".action = spawn [ "pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%" ];
      "XF86AudioLowerVolume".action = spawn [ "pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%" ];
      "XF86AudioMute".action        = spawn [ "pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle" ];

      # ── Portapapeles ──────────────────────────────────────────
      # Noctalia integra cliphist en su launcher — este atajo abre el picker
      # Si prefieres un comando directo: spawn ["bash" "-c" "cliphist list | ..."]
      "Mod+Shift+X".action = spawn [ "bash" "-c" "cliphist list | noctalia-shell ipc clipboard-pick | cliphist decode | wl-copy" ];

      # ── Foco (columnas y ventanas) ────────────────────────────
      "Mod+Left".action        = focus-column-left;
      "Mod+Right".action       = focus-column-right;
      "Mod+Up".action          = focus-window-up;
      "Mod+Down".action        = focus-window-down;
      "Mod+H".action           = focus-column-left;
      "Mod+L".action           = focus-column-right;
      "Mod+K".action           = focus-window-up;
      "Mod+J".action           = focus-window-down;

      # ── Mover ventanas ────────────────────────────────────────
      "Mod+Shift+Left".action  = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action    = move-window-up;
      "Mod+Shift+Down".action  = move-window-down;

      # ── Workspaces ────────────────────────────────────────────
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;
      "Mod+0".action = focus-workspace 10;

      "Mod+Shift+1".action = move-column-to-workspace 1;
      "Mod+Shift+2".action = move-column-to-workspace 2;
      "Mod+Shift+3".action = move-column-to-workspace 3;
      "Mod+Shift+4".action = move-column-to-workspace 4;
      "Mod+Shift+5".action = move-column-to-workspace 5;
      "Mod+Shift+6".action = move-column-to-workspace 6;
      "Mod+Shift+7".action = move-column-to-workspace 7;
      "Mod+Shift+8".action = move-column-to-workspace 8;
      "Mod+Shift+9".action = move-column-to-workspace 9;
      "Mod+Shift+0".action = move-column-to-workspace 10;

      # Scroll entre workspaces con rueda del ratón
      "Mod+WheelScrollUp".action   = focus-workspace-up;
      "Mod+WheelScrollDown".action = focus-workspace-down;

      # ── Diseño ────────────────────────────────────────────────
      "Mod+F".action           = fullscreen-window;
      "Mod+Shift+Space".action = toggle-window-floating;
      "Mod+Space".action       = switch-focus-between-floating-and-tiling;

      # Scroll por columnas (propio de Niri — no existe en Sway)
      "Mod+Shift+WheelScrollUp".action   = focus-column-left;
      "Mod+Shift+WheelScrollDown".action = focus-column-right;

      # ── CPU profiles (tus aliases siguen funcionando en terminal) ─
      "Mod+F5".action = spawn [ "sudo" "/run/current-system/sw/bin/perfil-cpu" "normal" ];
      "Mod+F6".action = spawn [ "sudo" "/run/current-system/sw/bin/perfil-cpu" "turbo" ];
    };

    # ── Reglas de ventana ─────────────────────────────────────
    # Adaptadas desde tus for_window de Sway.
    # En Niri no hay inhibit_idle por regla — las apps gestionan idle
    # directamente con el protocolo Wayland (funciona mejor que en Sway).
    window-rules = [
      # Sakura — flotante con opacidad
      {
        matches = [{ app-id = "sakura"; }];
        open-floating = true;
        default-column-width = { proportion = 0.45; };
        opacity = 0.95;
      }
      # Steam — flotante
      {
        matches = [{ app-id = "steam"; }];
        open-floating = true;
      }
      # Pavucontrol — flotante
      {
        matches = [{ app-id = "pavucontrol"; }];
        open-floating = true;
        default-column-width = { proportion = 0.35; };
      }
      # Blood Strike
      {
        matches = [{ app-id = "bloodstrike\\.exe"; }];
        open-fullscreen = true;
      }
      # L4D2 / Source Engine
      {
        matches = [{ app-id = "hl2_linux"; }];
        open-fullscreen = true;
      }
      # DOOM
      {
        matches = [{ app-id = "DOOMBoard"; }];
        open-fullscreen = true;
      }
      {
        matches = [{ app-id = "DoomEternal"; }];
        open-fullscreen = true;
      }
      # Roblox (Sober Flatpak)
      {
        matches = [{ app-id = "org\\.sober\\.Sober"; }];
        open-fullscreen = true;
      }
    ];
  };

  # ── Noctalia — desktop shell unificado ────────────────────────
  # Reemplaza: Waybar + Rofi + Wlogout + Swaylock + Swayidle + Wlsunset
  programs.noctalia-shell = {
    enable = true;

    # ── Paleta de colores (Glassmorphism espacial) ────────────────
    # Basada en tu waybar/colors.css y tu tema de Sway
    # Material 3 color system requerido por Noctalia v4
    colors = {
      mBackground          = "#1a1b26"; # Tokyo Night base
      mOnBackground        = "#c0caf5"; # texto principal
      mSurface             = "#16161e"; # paneles
      mOnSurface           = "#c0caf5";
      mPrimary             = "#00d4ff"; # cian neón (acento principal)
      mOnPrimary           = "#0a0a0a";
      mSecondary           = "#8a2be2"; # morado nebulosa
      mOnSecondary         = "#ffffff";
      mTertiary            = "#7aa2f7"; # azul suave
      mOnTertiary          = "#0a0a0a";
      mError               = "#f7768e"; # rojo suave
      mOnError             = "#0a0a0a";
      mSurfaceVariant      = "#3b4261"; # surface oscura alternativa
      mOnSurfaceVariant    = "#a9b1d6"; # texto secundario
      mOutline             = "#545c7e"; # bordes
      mShadow              = "#000000";
      mInverseSurface      = "#c0caf5";
      mInverseOnSurface    = "#1a1b26";
      mInversePrimary      = "#0a8caa";
      mSurfaceTint         = "#00d4ff";
      mScrim               = "#000000";
    };

    # ── Configuración del shell ───────────────────────────────────
    settings = {

      # Barra superior
      bar = {
        position          = "top";
        backgroundOpacity = 0.88;
        # Widgets: configurar desde la GUI de Noctalia tras el primer arranque
        # o añadir aquí según documentación de la versión instalada
      };

      # Dock inferior (auto-hide)
      dock = {
        enabled     = true;
        position    = "bottom";
        displayMode = "auto_hide";
        pinnedApps  = [
          "chromium"
          "obsidian"
          "vesktop"
          "steam"
          "org.gnome.Nautilus"
          "sakura"
        ];
      };

      # Luz nocturna (reemplaza wlsunset)
      # Ajuste: 7pm → 3500K, 7am → 6500K (igual que tu wlsunset anterior)
      nightLight = {
        enabled       = false; # activar manualmente cuando lo quieras
        nightTemp     = "3500";
        dayTemp       = "6500";
        manualSunrise = "07:00";
        manualSunset  = "19:00";
      };

      # Menú de sesión (reemplaza wlogout)
      sessionMenu.enabled = true;

      # Idle / lock (reemplaza swayidle + swaylock)
      idle = {
        enabled          = true;
        screenOffTimeout = 600;  # 10 min → apagar pantalla
        lockTimeout      = 660;  # 11 min → bloquear
        suspendTimeout   = 1800; # 30 min → suspender
      };

      # General
      general = {
        lockOnSuspend    = true;
        telemetryEnabled = false;
      };
    };
  };
}
