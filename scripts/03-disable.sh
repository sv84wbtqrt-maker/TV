#!/bin/bash
# Étape 3 : DÉSACTIVER (pas supprimer) les applis listées dans un fichier.
# Usage : ./scripts/03-disable.sh packages/approved.txt
# - une appli par ligne, les lignes commençant par # sont ignorées ;
# - confirmation demandée pour chaque appli (o = oui, n = non, t = oui pour toutes, q = quitter) ;
# - chaque appli désactivée est notée dans state/undo-list.txt -> annulable avec 99-undo.sh.
. "$(dirname "$0")/lib.sh"
load_device

LIST="${1:-}"
[ -n "$LIST" ] && [ -f "$LIST" ] || die "Usage : ./scripts/03-disable.sh packages/approved.txt"

ALL=0
done_n=0; skip_n=0; fail_n=0

while IFS= read -r line || [ -n "$line" ]; do
  p="$(echo "${line%%#*}" | tr -d '[:space:]')"
  [ -n "$p" ] || continue

  if is_protected "$p"; then
    echo "PROTÉGÉE, ignorée : $p"; skip_n=$((skip_n+1)); continue
  fi
  if ! tv pm list packages | grep -qx "package:$p"; then
    echo "Absente de cette TV, ignorée : $p"; skip_n=$((skip_n+1)); continue
  fi
  if tv pm list packages -d | grep -qx "package:$p"; then
    echo "Déjà désactivée : $p"; skip_n=$((skip_n+1)); continue
  fi

  if [ "$ALL" -ne 1 ]; then
    a="$(ask "Désactiver $p ? [o/n/t/q]")"
    case "$a" in
      t|T) ALL=1 ;;
      o|O|y|Y) ;;
      q|Q) echo "Arrêt demandé."; break ;;
      *) echo "  -> conservée"; skip_n=$((skip_n+1)); continue ;;
    esac
  fi

  res="$(tv pm disable-user --user 0 "$p" 2>&1)"
  if echo "$res" | grep -qi "disabled"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') $p" >> "$UNDO_LIST"
    echo "  -> désactivée : $p"; done_n=$((done_n+1))
  else
    echo "  -> ÉCHEC, Fire OS protège cette appli (sans gravité) : $p : $(echo "$res" | grep -m1 -i exception)"
    fail_n=$((fail_n+1))
  fi
done < "$LIST"

echo
echo "Terminé : $done_n désactivée(s), $skip_n ignorée(s), $fail_n échec(s)."
echo "Liste d'annulation : $UNDO_LIST"
echo "Conseil : redémarrez maintenant pour vérifier -> ./scripts/05-reboot-check.sh"
