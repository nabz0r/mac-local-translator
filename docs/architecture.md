# Architecture de Mac Local Translator

## Vue d'ensemble

L'application est construite sur une architecture modulaire visant à séparer clairement les responsabilités tout en optimisant les performances pour une utilisation locale.

## Composants clés

### 1. Interface utilisateur (UI)

Construit avec SwiftUI pour une expérience native macOS :

- `MainView` : Fenêtre principale de l'application
- `ConversationView` : Affiche la conversation traduite en temps réel
- `LanguageSelector` : Permet à l'utilisateur de sélectionner les langues source et cible
- `SettingsView` : Configuration des paramètres de l'application

### 2. Gestion audio

- `AudioRecorder` : Capture l'audio depuis le microphone
- `AudioPlayer` : Lecture des traductions via la synthèse vocale
- `VADService` (Voice Activity Detection) : Détecte quand quelqu'un commence et arrête de parler

### 3. Reconnaissance vocale

- `SpeechRecognizer` : Interface avec Whisper.cpp pour la transcription
- `WhisperManager` : Gère le cycle de vie des modèles et optimise les ressources

### 4. Traduction

- `TranslationEngine` : Interface avec LibreTranslate/Argos Translate
- `TranslationManager` : Gère les modèles de langue et optimise les performances

### 5. Synthèse vocale

- `SpeechSynthesizer` : Utilise AVSpeechSynthesizer pour convertir le texte traduit en parole

### 6. Gestion des modèles

- `ModelManager` : Gère le téléchargement, la mise à jour et l'optimisation des modèles

### 7. Stockage et préférences

- `PreferencesManager` : Gère les paramètres utilisateur
- `ConversationStore` : Stocke l'historique des conversations

## Flux de données

1. **Acquisition audio** : L'audio est capturé via le microphone et tamponné en mémoire
2. **Détection d'activité vocale** : Le système détecte quand une personne commence/arrête de parler
3. **Reconnaissance vocale** : L'audio capturé est transcrit en texte
4. **Traduction** : Le texte transcrit est traduit vers la langue cible
5. **Synthèse vocale** : Le texte traduit est converti en parole
6. **Présentation** : Les textes source et traduit sont affichés dans l'interface utilisateur

## Considérations techniques

### Performances

- Les modèles sont chargés en mémoire de manière optimisée
- Utilisation du GPU pour l'accélération quand disponible
- Quantification des modèles pour réduire l'empreinte mémoire

### Multi-threading

- Traitement audio en temps réel sur un thread dédié
- Reconnaissance vocale et traduction sur des threads séparés
- Interface utilisateur fluide grâce à une architecture asynchrone

### Securité et confidentialité

- Toutes les données restent sur l'appareil
- Aucune connexion réseau n'est requise pour le fonctionnement de base

## Diagramme des composants

```
+------------------+      +------------------+      +------------------+
|                  |      |                  |      |                  |
|  Interface       |<---->|  Contrôleurs    |<---->|  Modèles         |
|  Utilisateur     |      |  d'application  |      |                  |
|                  |      |                  |      |                  |
+------------------+      +------------------+      +------------------+
         ^                        ^                         ^
         |                        |                         |
         v                        v                         v
+------------------+      +------------------+      +------------------+
|                  |      |                  |      |                  |
|  Système Audio   |<---->| Reconnaissance   |<---->|  Traduction     |
|  (Entrée/Sortie) |      | Vocale          |      |                  |
|                  |      |                  |      |                  |
+------------------+      +------------------+      +------------------+
```