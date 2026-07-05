# ~/nixos-config-niri/home.nix
# Configuración de usuario vía Home Manager
# Gestiona: Niri (compositor) + Noctalia (shell) + scripts
# Se aplica automáticamente durante nixos-rebuild switch

{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    # Módulo HM de Niri — habilita programs.niri.settings
    #inputs.niri-flake.homeModules.niri
    # Módulo HM de Noctalia — habilita programs.noctalia-shell
    inputs.noctalia.homeModules.default
  ];

  # ── Identidad de Home Manager ────────────────────────────────
  home.username    = "lonso";
  home.homeDirectory = "/home/lonso";
  home.stateVersion  = "26.05";

  # ── Niri — compositor Wayland ─────────────────────────────────
home.file = {
  ".config/niri/config.kdl".source = ./niri-config.kdl;
  ".config/niri/scripts/screenshot.sh" = {
    source = ./scripts/screenshot-niri.sh;
    executable = true;   # ← añade esto
  };
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
  settings = builtins.fromJSON (builtins.readFile ./noctalia-settings.json);
  };
}
