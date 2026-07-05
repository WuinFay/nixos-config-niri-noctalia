# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# ── Oh My Bash ────────────────────────────
export OSH='/home/lonso/.oh-my-bash'
OSH_THEME="lambda"
OMB_USE_SUDO=true

completions=(git composer ssh)
aliases=(general)
plugins=(git bashmarks)

source "$OSH"/oh-my-bash.sh

# ── PATH personalizado ────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Optimizaciones del Sistema ────────────
export MAKEFLAGS="-j$(nproc)"
export DXVK_STATE_CACHE=1
export MESA_SHADER_CACHE_DISABLE=false



# ── Aliases ───────────────────────────────
alias gamemode='gamemoderun'
alias grabar='wf-recorder -f "/run/media/lonso/ALONSOUSB/$(date +"%Y%m%d_%H%M%S").mp4"'
alias normal='sudo /run/current-system/sw/bin/perfil-cpu normal'
alias turbo='sudo /run/current-system/sw/bin/perfil-cpu turbo'
alias nadmin='nautilus admin:///'

# 1. Actualizar el sistema localmente (sin subir a GitHub)
alias actualizar='sudo nixos-rebuild switch --flake ~/nixos-config#nixos'


# 2. Revisar el Flake sin modificar nada
alias revisar='cd ~/nixos-config && nix flake check'


# 3. Copiar dotfiles de ~/.config al repo (paso previo a respaldar)
alias copiar-config='\
  echo "📂 Copiando dotfiles esenciales al repo..." && \
  cp ~/.bashrc ~/nixos-config/dotfiles/.bashrc && \
  for dir in fastfetch gtk-3.0 gtk-4.0 rofi sakura sway waybar wlogout; do \
    if [ -d ~/.config/$dir ]; then \
      cp -r ~/.config/$dir ~/nixos-config/dotfiles/.config/; \
    else \
      echo "⚠️  Omitido: ~/.config/$dir no existe"; \
    fi; \
  done && \
  echo "✅ Dotfiles copiados. Ahora ejecuta: respaldar"'
alias copiar-config-niri='\
  echo "📂 Copiando dotfiles al repo Niri..." && \
  cp ~/.bashrc ~/nixos-config-niri/dotfiles/.bashrc && \
  for dir in fastfetch gtk-3.0 gtk-4.0 sakura; do \
    if [ -d ~/.config/$dir ]; then \
      cp -r ~/.config/$dir ~/nixos-config-niri/dotfiles/.config/; \
    else \
      echo "⚠️  Omitido: ~/.config/$dir no existe"; \
    fi; \
  done && \
  echo "✅ Dotfiles copiados. Ahora ejecuta: respaldar-niri"'
# 4. Commit y push al repo (ejecutar después de copiar-config)
alias respaldar='\
  cd ~/nixos-config && \
  git add -A && \
  git commit -m "Backup: $(date +%d-%m-%Y_%H:%M)" && \
  git push --force-with-lease origin main'
# ── Juegos ──────────────────────────────────
alias tmod="cd $HOME/Tmod/tModLoader && ./start-tModLoaderServer.sh -config serverconfig.txt"

alias terra="cd $HOME/Terraria_Vanilla/terraria-server-1456/1456/Linux && ./TerrariaServer.bin.x86_64"

alias mcjava="cd $HOME/minecraft-server && bash run.sh nogui"

alias playit='~/.local/bin/playit --socket-path /tmp/playit-manual.socket &'
# ── Niri + Noctalia ──────────────────────────────────────────
# Nota: el repo Niri no necesita copiar-config separado — los dotfiles
# están gestionados por home.nix (Home Manager) directamente en el repo.

alias actualizar-niri='sudo nixos-rebuild switch --flake ~/nixos-config-niri#nixos'
alias revisar-niri='cd ~/nixos-config-niri && nix flake check'
alias recargar-niri='niri msg action load-config-file ~/.config/niri/config.kdl'

alias respaldar-niri='\
  cd ~/nixos-config-niri && \
  git add -A && \
  git commit -m "Backup: $(date +%d-%m-%Y_%H:%M)" && \
  git push --force-with-lease origin main'
# ── Bienvenida ────────────────────────────
CIAN='\033[0;36m'
BLANCO='\033[1;37m'
NC='\033[0m'

function navegacion {
    if [ "$XDG_CURRENT_DESKTOP" = "niri" ]; then
        WM="Niri + Noctalia"
        ICON="🌀"
    else
        WM="Sway Window Manager"
        ICON="🚀"
    fi
    echo -e "${CIAN}${ICON} Sakura Terminal...${NC}"
    echo -e "${BLANCO}${WM} | NixOS${NC}"
    echo -e "${CIAN}────────────────────────────────────────────${NC}"
    echo -e "Usuario: ${BLANCO}$(whoami)${NC} | Host: ${BLANCO}$(hostname)${NC}"
    echo -e "${CIAN}────────────────────────────────────────────${NC}"
}



