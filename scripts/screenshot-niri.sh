#!/usr/bin/env bash
# ~/.config/niri/scripts/screenshot.sh
# Capturas de pantalla para Niri (corregido para JSON real)

SAVEDIR="$HOME/Imágenes/Capturas"
mkdir -p "$SAVEDIR"
FILENAME="$SAVEDIR/captura_$(date +%Y%m%d_%H%M%S).png"

MODE="${1:-screen}"

case "$MODE" in
  screen)
    grim "$FILENAME" && wl-copy < "$FILENAME" && notify-send "Captura" "Pantalla completa" --icon="$FILENAME"
    ;;
  area)
    REGION=$(slurp 2>/dev/null) || exit 0
    grim -g "$REGION" "$FILENAME" && wl-copy < "$FILENAME" && notify-send "Captura" "Área seleccionada" --icon="$FILENAME"
    ;;
  active)
    # Obtener JSON de la ventana enfocada
    WINDOW_JSON=$(niri msg --json focused-window 2>/dev/null)
    if [ -z "$WINDOW_JSON" ] || [ "$WINDOW_JSON" = "null" ]; then
      notify-send "Captura" "No hay ventana enfocada" && exit 1
    fi

    # Extraer offset y tamaño desde layout
    X=$(echo "$WINDOW_JSON" | jq -r '.layout.window_offset_in_tile[0] // empty')
    Y=$(echo "$WINDOW_JSON" | jq -r '.layout.window_offset_in_tile[1] // empty')
    W=$(echo "$WINDOW_JSON" | jq -r '.layout.window_size[0] // empty')
    H=$(echo "$WINDOW_JSON" | jq -r '.layout.window_size[1] // empty')

    if [ -z "$X" ] || [ -z "$Y" ] || [ -z "$W" ] || [ -z "$H" ]; then
      # Fallback a slurp si algo falla
      REGION=$(slurp 2>/dev/null) || exit 0
      grim -g "$REGION" "$FILENAME"
    else
      REGION="${X},${Y} ${W}x${H}"
      grim -g "$REGION" "$FILENAME"
    fi

    wl-copy < "$FILENAME" && notify-send "Captura" "Ventana activa" --icon="$FILENAME"
    ;;
  *)
    echo "Uso: screenshot.sh [screen|area|active]"
    exit 1
    ;;
esac

echo "Guardado en: $FILENAME"
