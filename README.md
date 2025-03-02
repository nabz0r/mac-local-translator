# Mac Local Translator

Application de traduction locale pour Mac qui utilise le microphone pour écouter les personnes parler à tour de rôle et traduire leurs propos, similaire à Google Traducteur mais entièrement en local.

## Caractéristiques

- **Entièrement local** : Aucune connexion internet requise pour le fonctionnement
- **Respect de la vie privée** : Les données vocales ne quittent jamais votre appareil
- **Interface intuitive** : Simple à utiliser pour faciliter les conversations multilingues
- **Traduction bidirectionnelle** : Permet à deux personnes parlant des langues différentes de converser
- **Utilisation de modèles optimisés** : Équilibre entre précision et performances

## Technologie

- **Frontend**: SwiftUI pour une interface native macOS
- **Reconnaissance vocale**: Whisper.cpp (modèle local optimisé)
- **Traduction**: LibreTranslate/Argos Translate (modèles locaux)
- **Synthèse vocale**: API AVSpeechSynthesizer de macOS

## Installation

Consultez le guide d'installation dans [docs/setup.md](docs/setup.md).

## Utilisation

Consultez le guide utilisateur dans [docs/user_guide.md](docs/user_guide.md).

## Architecture

Consultez la documentation d'architecture dans [docs/architecture.md](docs/architecture.md).

## Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.