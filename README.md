# Nettoyage de la TV Insignia (Fire TV)

Scripts pour accélérer une **Insignia NS-39F201NA23** (Fire TV, écran LED) en
**désactivant** (pas en supprimant) les applis système inutiles. Tout est annulable.

On garde : l'accueil, les **Paramètres**, les entrées **HDMI**, l'**USB**, les
**chaînes TV**, la télécommande et Alexa, les mises à jour, les principales applis
de **streaming** et la **recopie d'écran**. Un filet de sécurité (`PROTECTED_REGEX`
dans `scripts/lib.sh`) refuse de toucher à ces applis, même si on se trompe dans une liste.

## Ce qu'il faut avant de commencer

1. **Sur la TV**
   - Paramètres > Ma Fire TV > À propos : cliquez **7 fois** sur le nom de la TV.
   - Revenez en arrière > **Options pour les développeurs** > **Débogage ADB : activé**.
   - Paramètres > Ma Fire TV > À propos > **Réseau** : notez l'**adresse IP**.
2. **Sur le Mac** (même Wi-Fi que la TV), dans Terminal :
   ```bash
   brew install android-platform-tools
   git clone https://github.com/sv84wbtqrt-maker/tv.git
   cd tv
   chmod +x scripts/*.sh
   ```

## Étapes

| # | Commande | Ce qu'elle fait | Modifie la TV ? |
|---|----------|-----------------|-----------------|
| 1 | `./scripts/01-connect.sh 192.168.x.x` | Connexion Wi-Fi (acceptez la demande à l'écran) | Non |
| 2 | `./scripts/02-audit.sh` | Inventaire des applis, de la mémoire et des réglages dans `audit/` | Non |
| 3 | `./scripts/03-disable.sh packages/approved.txt` | Désactive les applis validées, avec une confirmation par appli | Oui (annulable) |
| 4 | `./scripts/04-tweaks.sh` | Coupe les animations, veille après 5 min | Oui (annulable) |
| 5 | `./scripts/05-reboot-check.sh` | Redémarre et vérifie le démarrage | Non |
| 6 | `./scripts/06-finish.sh` | Se déconnecte et rappelle de couper le débogage | Non |

Après l'étape 2, envoyez à Claude le contenu du dossier `audit/…` (ou poussez-le
sur GitHub). Claude prépare alors `packages/approved.txt`, que vous validez
avant l'étape 3. `packages/candidates.txt` ne contient que des pistes.

## Annuler

```bash
./scripts/99-undo.sh                 # tout annuler (applis + réglages)
./scripts/99-undo.sh com.amazon.xxx  # réactiver une seule appli
```

L'historique est dans `state/undo-list.txt` et `state/settings-backup.txt`.
Pensez à les pousser sur GitHub pour ne pas les perdre.

**Si la TV reste bloquée sur le logo** : débranchez-la 1 minute. Si ça ne suffit
pas, lancez `./scripts/99-undo.sh` dès qu'elle répond à nouveau. En dernier
recours : réinitialisation d'usine (bouton physique ou menu de récupération).

## Recopie d'écran depuis un iPhone

Fire TV ne gère pas AirPlay nativement. Sa « recopie d'écran » intégrée ne
fonctionne qu'avec Android. Pour un iPhone, installez une appli réceptrice depuis
l'Appstore Amazon, par exemple **AirScreen**. Elle est protégée par les scripts.

## Ce qui n'est pas fait, et pourquoi

- **Lanceur personnalisé (tv-detox, etc.)** : Fire OS bloque le remplacement de
  l'accueil Amazon, et les contournements cassent à chaque mise à jour.
- **Économiseur d'écran anti-marquage** : inutile, l'écran est LED et non OLED.

## Pour finir

Désactivez **Débogage ADB** sur la TV (étape 6). Sinon, n'importe quel appareil
de votre Wi-Fi pourrait contrôler la TV.
