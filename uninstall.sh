#!/usr/bin/env bash
# Désinstalle « Fonds animés » (les fonds du Workshop et Steam ne sont pas touchés).
set -euo pipefail
BIN_DIR="$HOME/.local/bin"
"$BIN_DIR/fond-anime" stop 2>/dev/null || true
rm -f "$BIN_DIR/fond-anime" "$BIN_DIR/fond-anime-selecteur" \
      "${XDG_DATA_HOME:-$HOME/.local/share}/applications/fond-anime-selecteur.desktop" \
      "${XDG_CONFIG_HOME:-$HOME/.config}/autostart/fond-anime.desktop"
echo "Scripts retirés."
echo "Pour supprimer aussi la version compilée et les réglages :"
echo "  rm -rf \"${XDG_DATA_HOME:-$HOME/.local/share}/fonds-animes\" \"${XDG_CONFIG_HOME:-$HOME/.config}/fond-anime\""
