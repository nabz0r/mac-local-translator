# Guide de contribution à Mac Local Translator

Merci de votre intérêt pour contribuer à Mac Local Translator ! Ce document fournit des directives pour contribuer au projet et assurer un processus de développement collaboratif efficace.

## Processus de contribution

### Signaler des bugs

Si vous avez identifié un bug ou un problème :

1. Vérifiez que le bug n'a pas déjà été signalé dans les issues GitHub.
2. Utilisez le modèle de rapport de bug pour créer une nouvelle issue.
3. Incluez des étapes de reproduction détaillées et, si possible, des captures d'écran.
4. Mentionnez votre environnement (OS, version de macOS, etc.).

### Proposer des améliorations

Pour proposer de nouvelles fonctionnalités ou améliorations :

1. Ouvrez une issue en utilisant le modèle de demande de fonctionnalité.
2. Décrivez clairement la fonctionnalité, son cas d'utilisation et comment elle s'intègre au projet.
3. Si possible, indiquez les composants qui devront être modifiés.

### Soumettre des modifications

Pour contribuer du code :

1. Faites un fork du dépôt et créez une branche à partir de `main`.
2. Nommez votre branche de manière descriptive (ex: `feature/new-translation-engine` ou `fix/audio-recording-issue`).
3. Suivez les conventions de codage listées ci-dessous.
4. Assurez-vous que les tests couvrent vos modifications.
5. Créez une Pull Request avec une description claire de vos changements.

## Conventions de codage

### Style de code

- Suivez le [guide de style Swift d'Apple](https://swift.org/documentation/api-design-guidelines/).
- Utilisez 4 espaces pour l'indentation (pas de tabulations).
- Limitez les lignes à 100 caractères lorsque c'est raisonnable.
- Organisez votre code avec des marques MARK pour améliorer la lisibilité.

### Documentation

- Documentez toutes les méthodes et propriétés publiques avec des commentaires compatibles avec Xcode (///). 
- Expliquez le "pourquoi" plutôt que le "quoi" dans vos commentaires.
- Mettez à jour la documentation utilisateur si nécessaire.

### Tests

- Écrivez des tests unitaires pour les nouvelles fonctionnalités.
- Maintenez la couverture de test à un niveau acceptable.
- Exécutez les tests avant de soumettre une PR.

## Architecture du projet

Mac Local Translator suit une architecture modulaire avec les composants principaux suivants :

- **Models** : Contient les structures de données et la logique métier.
- **Views** : Implémente l'interface utilisateur avec SwiftUI.
- **Services** : Gère les fonctionnalités spécifiques (audio, reconnaissance vocale, traduction).
- **Coordinator** : Orchestre les interactions entre les services.
- **Utils** : Fournit des utilitaires et des extensions réutilisables.

Lors de l'implémentation de nouvelles fonctionnalités, respectez cette séparation des responsabilités.

## Configuration de l'environnement de développement

### Prérequis

- macOS 12.0 ou plus récent
- Xcode 14.0 ou plus récent
- Swift 5.7 ou plus récent

### Outils recommandés

- [SwiftLint](https://github.com/realm/SwiftLint) pour analyser le code
- [Jazzy](https://github.com/realm/jazzy) pour générer la documentation

### Configuration initiale

1. Clonez le dépôt : `git clone https://github.com/nabz0r/mac-local-translator.git`
2. Exécutez `make download-models` pour télécharger les modèles requis
3. Ouvrez le projet dans Xcode ou utilisez `swift build` pour compiler

## Processus de publication

Le projet suit le versionnement sémantique (MAJOR.MINOR.PATCH) :

- MAJOR : changements incompatibles avec les versions précédentes
- MINOR : ajouts de fonctionnalités compatibles avec les versions précédentes
- PATCH : corrections de bugs compatibles avec les versions précédentes

L'intégration continue est configurée pour construire et tester automatiquement les Pull Requests et les tags. Les versions sont automatiquement publiées lorsqu'un nouveau tag est créé.

## Communication

- Utilisez les issues GitHub pour les discussions techniques.
- Maintenez un ton respectueux et professionnel dans toutes les communications.
- Pour les discussions plus longues, envisagez d'utiliser les discussions GitHub.

## Licence

En contribuant à ce projet, vous acceptez que vos contributions soient sous la même licence que le projet (MIT).

Merci de contribuer à Mac Local Translator !