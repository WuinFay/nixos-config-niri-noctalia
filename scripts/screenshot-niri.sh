#!/usr/bin/env bash
# ~/.config/niri/scripts/screenshot.sh
# Capturas de pantalla para Niri compositor
# Adaptado desde ~/.config/sway/scripts/screenshot.sh
#
# Diferencias clave vs Sway:
#   - No usa swaymsg → usa `niri msg --json` para info de ventanas
#   - Requiere: grim, slurp, wl-clipboard, jq
# ──────────────────────────────────────────────────────────────

# Directorio de destino — créalo si no existe
SAVEDIR="$HOME/Imágenes/Capturas"
mkdir -p "$SAVEDIR"

# Nombre del archivo con timestamp
FILENAME="$SAVEDIR/captura_$(date +%Y%m%d_%H%M%S).png"

MODE="${1:-screen}"

case "$MODE" in

  # ── Pantalla completa ──────────────────────────────────────
  screen)
    grim "$FILENAME" && \
      wl-copy < "$FILENAME" && \
      notify-send "Captura de pantalla" "Pantalla completa guardada" \
        --icon="$FILENAME" 2>/dev/null || true
    ;;

  # ── Área seleccionada con slurp ───────────────────────────
  area)
    REGION=$(slurp 2>/dev/null) || exit 0
    grim -g "$REGION" "$FILENAME" && \
      wl-copy < "$FILENAME" && \
      notify-send "Captura de pantalla" "Área seleccionada guardada" \
        --icon="$FILENAME" 2>/dev/null || true
    ;;

  # ── Ventana activa ────────────────────────────────────────
  # Niri expone la geometría de la ventana enfocada vía IPC.
  # A diferencia de Sway (que usaba swaymsg -t get_tree),
  # Niri usa: niri msg --json focused-window
  active)
    # Obtener geometría de la ventana enfocada
    WINDOW_JSON=$(niri msg --json focused-window 2>/dev/null)

    if [ -z "$WINDOW_JSON" ] || [ "$WINDOW_JSON" = "null" ]; then
      notify-send "Captura de pantalla" "No hay ventana enfocada" 2>/dev/null || true
      exit 1
    fi

    # Extraer coordenadas con jq
    X=$(echo "$WINDOW_JSON"      | jq -r '.geometry.x      // empty')
    Y=$(echo "$WINDOW_JSON"      | jq -r '.geometry.y      // empty')
    W=$(echo "$WINDOW_JSON"      | jq -r '.geometry.width  // empty')
    H=$(echo "$WINDOW_JSON"      | jq -r '.geometry.height // empty')

    if [ -z "$X" ] || [ -z "$Y" ] || [ -z "$W" ] || [ -z "$H" ]; then
      # Fallback: si la geometría no está disponible en la versión de Niri,
      # abrir slurp para que el usuario seleccione la ventana manualmente
      notify-send "Captura de pantalla" \
        "Geometría no disponible — selecciona la ventana manualmente" \
        2>/dev/null || true
      REGION=$(slurp 2>/dev/null) || exit 0
      grim -g "$REGION" "$FILENAME"
    else
      REGION="${X},${Y} ${W}x${H}"
      grim -g "$REGION" "$FILENAME"
    fi

    wl-copy < "$FILENAME" && \
      notify-send "Captura de pantalla" "Ventana activa guardada" \
        --icon="$FILENAME" 2>/dev/null || true
    ;;

  *)
    echo "Uso: screenshot.sh [screen|area|active]"
    exit 1
    ;;
esac

echo "Guardado en: $FILENAME"
