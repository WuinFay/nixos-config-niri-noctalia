#!/usr/bin/env bash
# cpu-profile-status.sh
# Muestra el estado actual del perfil de CPU (normal/turbo)
# Usado como fuente de datos para widgets de barra o terminal
#
# Salida estándar: texto simple legible por Noctalia u otras barras
# Salida JSON: para integraciones con widgets custom
#
# Uso:
#   cpu-profile-status.sh          → texto simple (Normal / Turbo)
#   cpu-profile-status.sh --json   → JSON para widgets
#   cpu-profile-status.sh --waybar → formato Waybar (legacy, mantenido por compatibilidad)
# ──────────────────────────────────────────────────────────────

STATUS_FILE="/tmp/cpu-profile-current"
BOOST_FILE="/sys/devices/system/cpu/amd_pstate/cpb"

# ── Detectar perfil actual ────────────────────────────────────
detect_profile() {
  # Prioridad 1: archivo de estado temporal (escrito por cpu-profile-toggle.sh)
  if [ -f "$STATUS_FILE" ]; then
    cat "$STATUS_FILE"
    return
  fi

  # Prioridad 2: leer directamente del kernel
  if [ -f "$BOOST_FILE" ]; then
    BOOST=$(cat "$BOOST_FILE")
    # En amd_pstate: cpb=0 → boost activo (turbo), cpb=1 → boost desactivado (normal)
    if [ "$BOOST" = "0" ]; then
      echo "turbo"
    else
      echo "normal"
    fi
    return
  fi

  # Fallback si no se puede detectar
  echo "unknown"
}

PROFILE=$(detect_profile)

# ── Formato de salida ─────────────────────────────────────────
case "${1:-text}" in

  --json)
    # Formato JSON — para widgets custom o integraciones
    case "$PROFILE" in
      turbo)
        printf '{"profile":"turbo","icon":"🔥","label":"Turbo","color":"#ff4b4b","class":"turbo"}\n'
        ;;
      normal)
        printf '{"profile":"normal","icon":"🧊","label":"Normal","color":"#00d4ff","class":"normal"}\n'
        ;;
      *)
        printf '{"profile":"unknown","icon":"❓","label":"Desconocido","color":"#555555","class":"unknown"}\n'
        ;;
    esac
    ;;

  --waybar)
    # Formato Waybar legacy (mantenido por si vuelves a Sway)
    # Waybar lee: {"text":"...", "tooltip":"...", "class":"..."}
    case "$PROFILE" in
      turbo)
        printf '{"text":"🔥 Turbo","tooltip":"Perfil: Turbo (boost activo)","class":"turbo"}\n'
        ;;
      normal)
        printf '{"text":"🧊 Normal","tooltip":"Perfil: Normal (boost desactivado)","class":"normal"}\n'
        ;;
      *)
        printf '{"text":"❓","tooltip":"Estado desconocido","class":"unknown"}\n'
        ;;
    esac
    ;;

  *)
    # Texto simple — para terminal y alias
    case "$PROFILE" in
      turbo)  echo "🔥 Turbo"   ;;
      normal) echo "🧊 Normal"  ;;
      *)      echo "❓ Desconocido" ;;
    esac
    ;;

esac
