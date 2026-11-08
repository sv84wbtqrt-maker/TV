#!/bin/bash
# Fonctions communes. Chargé par les autres scripts : ne pas lancer directement.
# Compatible avec le bash 3.2 fourni par macOS.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/config.local"
STATE="$ROOT/state"
AUDIT="$ROOT/audit"
UNDO_LIST="$STATE/undo-list.txt"
SETTINGS_BACKUP="$STATE/settings-backup.txt"

mkdir -p "$STATE" "$AUDIT"

die() { echo "ERREUR : $*" >&2; exit 1; }

command -v adb >/dev/null 2>&1 || die "adb introuvable. Installez-le : brew install android-platform-tools"

if [ -f "$CONFIG" ]; then
  # shellcheck disable=SC1090
  . "$CONFIG"
fi

load_device() {
  [ -n "${TV_IP:-}" ] || die "Adresse IP inconnue. Lancez d'abord : ./scripts/01-connect.sh <IP-de-la-TV>"
  export ANDROID_SERIAL="$TV_IP:5555"
  local st
  st="$(adb get-state 2>/dev/null || true)"
  if [ "$st" != "device" ]; then
    adb connect "$ANDROID_SERIAL" >/dev/null 2>&1 || true
    st="$(adb get-state 2>/dev/null || true)"
    [ "$st" = "device" ] || die "TV non connectée ($ANDROID_SERIAL). Vérifiez qu'elle est allumée et acceptez la demande ADB à l'écran."
  fi
}

# adb shell qui ne consomme pas l'entrée standard (indispensable dans les boucles « while read »).
tv() { adb shell "$@" </dev/null | tr -d '\r'; }

# Questions posées à l'utilisateur, même pendant une boucle qui lit un fichier.
ask() { local a; printf '%s ' "$1" >/dev/tty; read -r a </dev/tty; echo "$a"; }

# Applications qu'il ne faut JAMAIS désactiver : écran d'accueil, réglages, entrées HDMI,
# USB, TV, réseau, télécommande, mise à jour, applis de streaming, recopie d'écran.
PROTECTED_REGEX='launcher|settings|oobe|systemui|^android$|input|hdmi|tvinput|livetv|tuner|usb|mediaprovider|media\.|externalstorage|documentsui|bluetooth|wifi|network|connectivity|remote|keyboard|ime|inputmethod|ota|update|software|packageinstaller|permissioncontroller|webview|gms|frameworks|providers|phone|shell|vizzini|alexa|voice|netflix|youtube|avod|primevideo|disney|hulu|hbo|max|paramount|peacock|spotify|plex|twitch|appletv|airscreen|airplay|mirror|miracast|wfd|cast|display'

is_protected() { echo "$1" | grep -Eiq "$PROTECTED_REGEX"; }
