#!/usr/bin/env bash
# Installe « Fonds animés » pour l'utilisateur courant (aucun droit root requis, sauf pour les dépendances).
#   ./install.sh            : compile linux-wallpaperengine (avec le patch) et installe le sélecteur
#   ./install.sh --no-build : installe seulement les scripts (FOND_ANIME_BIN doit alors pointer vers l'exécutable)
set -euo pipefail

LWE_REPO="https://github.com/Almamu/linux-wallpaperengine.git"
LWE_COMMIT="a0ddce586e9ff12e9d31ca6b103f6036cc1b68fe"   # version testée avec le patch

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonds-animes"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
SRC="$DATA_DIR/linux-wallpaperengine"

DEPS="build-essential cmake git libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libgl-dev \
libglew-dev freeglut3-dev libsdl2-dev liblz4-dev libavcodec-dev libavformat-dev libavutil-dev \
libswscale-dev libxxf86vm-dev libglm-dev libglfw3-dev libmpv-dev mpv libpulse-dev libfftw3-dev \
libfreetype-dev libjack-jackd2-dev python3-gi gir1.2-gtk-3.0 x11-utils x11-xserver-utils"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mErreur :\033[0m %s\n' "$*" >&2; exit 1; }

[ "${XDG_SESSION_TYPE:-x11}" = "wayland" ] && \
  echo "Attention : session Wayland détectée. Ce projet est prévu pour X11 (Cinnamon, Xfce, MATE…)."

if [ "${1:-}" != "--no-build" ]; then
  if command -v dpkg >/dev/null; then
    # shellcheck disable=SC2086
    missing=$(dpkg-query -W -f='${db:Status-Abbrev} ${Package}\n' $DEPS 2>/dev/null | awk '$1!="ii"{print $2}'; \
              for p in $DEPS; do dpkg-query -W "$p" >/dev/null 2>&1 || echo "$p"; done)
    missing=$(echo "$missing" | sort -u | xargs)
    if [ -n "$missing" ]; then
      echo "Dépendances manquantes : $missing"
      echo "Installez-les avec :"
      echo "  sudo apt install $missing"
      echo "(libjack-jackd2-dev est volontaire : sans lui, apt peut retirer des bibliothèques audio utilisées par Steam.)"
      exit 1
    fi
  else
    echo "Système non Debian/Ubuntu : installez les équivalents de ces paquets puis relancez :"
    echo "  $DEPS"
  fi

  info "Récupération de linux-wallpaperengine ($LWE_COMMIT)"
  mkdir -p "$DATA_DIR"
  if [ ! -d "$SRC/.git" ]; then
    git clone --recurse-submodules "$LWE_REPO" "$SRC"
  fi
  git -C "$SRC" fetch --quiet origin
  git -C "$SRC" checkout --quiet --force "$LWE_COMMIT"
  git -C "$SRC" submodule update --init --recursive --quiet

  info "Application du patch « bascule sans trou »"
  git -C "$SRC" apply "$HERE/patches/x11-bascule-sans-trou.patch"

  info "Compilation (quelques minutes)"
  cmake -S "$SRC" -B "$SRC/build" -DCMAKE_BUILD_TYPE=Release >/dev/null
  cmake --build "$SRC/build" -j"$(nproc)"
  [ -x "$SRC/build/output/linux-wallpaperengine" ] || die "la compilation n'a pas produit l'exécutable"
fi

info "Installation des scripts dans $BIN_DIR"
mkdir -p "$BIN_DIR" "$APPS_DIR" "$AUTOSTART_DIR"
install -m 755 "$HERE/bin/fond-anime" "$HERE/bin/fond-anime-selecteur" "$BIN_DIR/"

cat > "$APPS_DIR/fond-anime-selecteur.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Fonds animés
Comment=Choisir un fond d'écran animé (Wallpaper Engine) pour chaque écran
Exec=$BIN_DIR/fond-anime-selecteur
Icon=preferences-desktop-wallpaper
Categories=Settings;DesktopSettings;
Keywords=wallpaper;fond;écran;animé;wallpaper engine;
EOF

cat > "$AUTOSTART_DIR/fond-anime.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Fonds animés
Comment=Relance le fond d'écran animé à l'ouverture de session
Exec=$BIN_DIR/fond-anime --auto
X-GNOME-Autostart-Delay=5
X-GNOME-Autostart-enabled=true
EOF

info "Terminé. Ouvrez « Fonds animés » depuis le menu des applications."
