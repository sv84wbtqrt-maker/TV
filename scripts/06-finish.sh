#!/bin/bash
# Étape 6 : fin de séance. Se déconnecte et rappelle de couper le débogage.
. "$(dirname "$0")/lib.sh"

[ -n "${TV_IP:-}" ] && adb disconnect "$TV_IP:5555" >/dev/null 2>&1 || true

cat <<'EOF'
Déconnecté.

IMPORTANT, sur la TV :
  Paramètres > Ma Fire TV > Options pour les développeurs
    -> Débogage ADB : DÉSACTIVÉ
Sinon, n'importe quel appareil de votre Wi-Fi pourrait prendre le contrôle de la TV.

Pensez à sauvegarder la liste d'annulation :
  git add state audit && git commit -m "Etat après nettoyage" && git push
EOF
