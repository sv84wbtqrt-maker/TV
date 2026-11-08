#!/bin/bash
# Étape 0 : installer adb sans Homebrew.
# Télécharge les « platform-tools » officiels de Google (~15 Mo) dans ~/platform-tools.
set -eu

DEST="$HOME/platform-tools"
URL="https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"

if [ -x "$DEST/adb" ]; then
  echo "adb est déjà installé : $DEST/adb"
  "$DEST/adb" version | head -1
  exit 0
fi

TMP="$(mktemp -d)"
echo "Téléchargement depuis Google..."
curl -fL --progress-bar -o "$TMP/pt.zip" "$URL"
echo "Décompression dans $HOME ..."
unzip -q "$TMP/pt.zip" -d "$HOME"
rm -rf "$TMP"

"$DEST/adb" version | head -1
echo
echo "adb installé dans $DEST. Les scripts le trouvent automatiquement."
echo "Suite : ./scripts/01-connect.sh <IP-de-la-TV>"
