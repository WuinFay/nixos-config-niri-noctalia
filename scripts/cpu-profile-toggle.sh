#!/usr/bin/env bash
# ~/.config/niri/scripts/cpu-profile-toggle.sh
# Alterna entre perfil normal y turbo del CPU
# Adaptado desde ~/.config/waybar/scripts/cpu-profile-toggle.sh
#
# Cambios respecto a la versión de Waybar:
#   - ELIMINADO: pkill -RTMIN+5 waybar (Waybar ya no existe)
#   - Noctalia no tiene widget nativo de CPU profile — el estado
#     se consulta con cpu-profile-status.sh desde terminal o keybind
#
# Requiere: sudo NOPASSWD para /run/current-system/sw/bin/perfil-cpu
#           (ya configurado en configuration.nix)
# ──────────────────────────────────────────────────────────────

PERFIL_CMD="/run/current-system/sw/bin/perfil-cpu"
STATUS_FILE="/tmp/cpu-profile-current"

# Leer perfil actual desde archivo temporal
# Si no existe, asumir normal como estado inicial
CURRENT=$(cat "$STATUS_FILE" 2>/dev/null || echo "normal")

if [ "$CURRENT" = "normal" ]; then
  # Cambiar a turbo
  sudo "$PERFIL_CMD" turbo
  echo "turbo" | tee "$STATUS_FILE" >/dev/null
  notify-send "Perfil CPU" "⚡ Modo TURBO activado" \
    --urgency=normal 2>/dev/null || true
  echo "Perfil cambiado a: turbo"
else
  # Cambiar a normal
  sudo "$PERFIL_CMD" normal
  echo "normal" | tee "$STATUS_FILE" >/dev/null
  notify-send "Perfil CPU" "🌿 Modo NORMAL activado" \
    --urgency=low 2>/dev/null || true
  echo "Perfil cambiado a: normal"
fi
