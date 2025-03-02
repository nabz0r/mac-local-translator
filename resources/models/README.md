# Répertoire des modèles

Ce répertoire contient les modèles utilisés par Mac Local Translator pour la reconnaissance vocale et la traduction.

## Structure

- `speech/` : Contient les modèles de reconnaissance vocale (Whisper)
- `translation/` : Contient les modèles de traduction (LibreTranslate/Argos Translate)

## Téléchargement

Les modèles ne sont pas inclus dans le dépôt Git en raison de leur taille. Utilisez le script `scripts/download_models.sh` pour télécharger les modèles nécessaires.

## Modèles supportés

### Reconnaissance vocale

- `whisper-tiny.bin` : Plus petit modèle (~75 Mo), performances limitées
- `whisper-small.bin` : Modèle équilibré (~500 Mo), bon pour la plupart des utilisations
- `whisper-medium.bin` : Modèle plus grand (~1.5 Go), meilleures performances

### Traduction

Les modèles de traduction suivent la convention de nommage `libre-translate-SOURCE-TARGET.bin`, où :
- `SOURCE` est le code de la langue source (ex: fr, en)
- `TARGET` est le code de la langue cible (ex: fr, en)

Exemples :
- `libre-translate-en-fr.bin` : Anglais vers Français
- `libre-translate-fr-en.bin` : Français vers Anglais
