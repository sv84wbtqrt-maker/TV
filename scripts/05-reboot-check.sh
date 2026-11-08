#!/bin/bash
# Étape 5 : redémarrer la TV et vérifier qu'elle démarre normalement.
. "$(dirname "$0")/lib.sh"
load_device

echo "Redémarrage de la TV..."
adb reboot
sleep 15

echo "Attente du démarrage (3 minutes maximum)..."
i=0
while [ $i -lt 36 ]; do
  adb connect "$ANDROID_SERIAL" >/dev/null 2>&1 || true
  if [ "$(adb shell getprop sys.boot_completed </dev/null 2>/dev/null | tr -d '\r')" = "1" ]; then
    echo "OK : la TV a démarré normalement."
    echo "Vérifiez à l'écran : accueil, applis de streaming, entrées HDMI, clé USB, chaînes TV, recopie d'écran."
    exit 0
  fi
  sleep 5; i=$((i+1))
done

echo "La TV n'a pas fini de démarrer après 3 minutes."
echo "Si elle reste bloquée sur le logo : débranchez-la 1 minute puis rebranchez."
echo "Si elle redémarre mais que quelque chose ne marche plus : ./scripts/99-undo.sh"
exit 1
