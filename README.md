# 🐧 NixOS Niri+Noctalia — Configuración personal

> Mi configuración personal de NixOS para Niri+Noctalia

Configuración personal de NixOS (Flakes) para un escritorio Wayland con **Niri** como
compositor y **Noctalia** (v4) como shell.

## Stack

- **NixOS unstable** (rolling release vía `nixpkgs`).
- **Niri** **25.08**.
- **Noctalia v4/legacy**
- **niriswitcher** (`pkgs.niriswitcher`, Python/GTK4) como switcher tipo Alt+Tab por workspace.
- **gpu-screen-recorder** + `gpu-screen-recorder-gtk` para grabación de pantalla (encoding por
  hardware, vía portal ScreenCast).

### Nota sobre `noctalia-settings.json`

cambiás algo
en la GUI de Noctalia → botón "copiar config" → pegás el JSON actualizado en este archivo →
commit. Se acepta así de manual a propósito

- Grabador de pantalla en uso es `gpu-screen-recorder`.

## Plugins de Noctalia instalados

- **Catwalk** — decorativo, gato animado en la barra.
- **Todo List** — gestor de tareas.
- **Pomodoro** — temporizador de productividad.
- **Clipper** — gestor de portapapeles con historial.
- **Obsidian Provider** — cambio entre vaults de Obsidian desde el launcher.
- **Keybind Cheatsheet** — overlay de atajos de Niri.
- **Privacy Indicator** — aviso visual de uso de micrófono/cámara/pantalla compartida.

## Licencia / uso

Configuración personal, sin licencia formal — usar como referencia bajo tu propio riesgo.
