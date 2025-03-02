# Guide d'installation de Mac Local Translator

## Configuration requise

- macOS 12.0 (Monterey) ou supérieur
- Processeur Intel ou Apple Silicon
- Minimum 8 GB de RAM (16 GB recommandés)
- 5 GB d'espace disque libre pour l'application et les modèles de base
- Microphone intégré ou externe

## Installation depuis les sources

### Prérequis

1. **Xcode** : Version 14.0 ou supérieure
2. **Swift** : Version 5.7 ou supérieure
3. **Git** : Pour cloner le dépôt
4. **Homebrew** (optionnel) : Pour installer des dépendances supplémentaires

### Étapes d'installation

1. **Cloner le dépôt**

   ```bash
   git clone https://github.com/nabz0r/mac-local-translator.git
   cd mac-local-translator
   ```

2. **Installer les dépendances**

   ```bash
   brew install cmake # Requis pour compiler Whisper.cpp
   ```

3. **Télécharger les modèles initiaux**

   ```bash
   ./scripts/download_models.sh
   ```

   Cette commande téléchargera les modèles de base pour :
   - Reconnaissance vocale (modèle Whisper medium)
   - Traduction (modèles français-anglais et anglais-français par défaut)

4. **Compiler l'application**

   Ouvrez le projet dans Xcode :
   ```bash
   open MacLocalTranslator.xcodeproj
   ```

   Puis dans Xcode :
   - Sélectionnez votre appareil cible
   - Cliquez sur Product > Build (ou utilisez CMD+B)

5. **Exécuter l'application**

   Toujours dans Xcode :
   - Cliquez sur Product > Run (ou utilisez CMD+R)

## Installation via le fichier DMG (lorsque disponible)

1. Téléchargez le fichier MacLocalTranslator.dmg depuis la page des releases
2. Montez l'image disque en double-cliquant sur le fichier DMG
3. Faites glisser l'application vers votre dossier Applications
4. Lancez l'application depuis le Launchpad ou le dossier Applications

## Configuration initiale

Au premier lancement, l'application vous guidera à travers :

1. La sélection des langues par défaut pour la reconnaissance et la traduction
2. Le téléchargement des modèles supplémentaires si nécessaire
3. La configuration du microphone et des paramètres audio

## Résolution des problèmes courants

### Problèmes d'accès au microphone

Si l'application ne peut pas accéder au microphone :

1. Accédez à Préférences Système > Confidentialité & Sécurité > Microphone
2. Assurez-vous que Mac Local Translator est autorisé à accéder au microphone

### Performance lente

Si l'application semble lente :

1. Vérifiez les autres applications en cours d'exécution qui pourraient consommer de la mémoire
2. Dans les préférences de l'application, essayez de sélectionner des modèles plus petits
3. Activez l'accélération GPU dans les paramètres si votre appareil le prend en charge

### Problèmes de traduction

Si les traductions semblent incorrectes :

1. Vérifiez que les bonnes langues source et cible sont sélectionnées
2. Essayez de parler plus clairement et plus lentement
3. Ajustez le niveau de sensibilité du microphone dans les paramètres