# 🏗️ Architecture Technique de Mac Local Translator

Ce document présente l'architecture technique complète de Mac Local Translator à travers des diagrammes visuels et des explications détaillées.

## 🖼️ Vue d'ensemble

```mermaid
C4Context
    title "Architecture globale de Mac Local Translator"
    
    Person(user, "Utilisateur", "Personne utilisant l'application pour la traduction")
    
    System_Boundary(app, "Mac Local Translator") {
        System(ui, "Interface Utilisateur", "Gestion des interactions et affichage")
        System(core, "Core Services", "Services principaux de l'application")
        System(models, "Modèles IA", "Modèles de reconnaissance vocale et traduction")
        System(data, "Gestion des Données", "Stockage et manipulation des états")
    }
    
    BiRel(user, ui, "Interagit avec")
    Rel(ui, core, "Utilise")
    Rel(core, models, "Exploite")
    Rel(core, data, "Manipule")
    Rel(ui, data, "Observe")
```

## 🔢 Décomposition des composants

### 1. Interface Utilisateur (SwiftUI)

```mermaid
flowchart TB
    subgraph "Interface Utilisateur"
        direction LR
        A[ContentView] --> B[ToolbarView]
        A --> C[ConversationView]
        A --> D[ControlPanelView]
        A --> E[SettingsView]
        
        B --> B1[LanguageSelector]
        B --> B2[RecordingButton]
        B --> B3[AudioLevelIndicator]
        
        C --> C1[MessageBubbleView]
        
        D --> D1[StatusSection]
        D --> D2[VolumeSection]
        D --> D3[ModelsSection]
        
        E --> E1[GeneralTab]
        E --> E2[AudioTab]
        E --> E3[ModelsTab]
        E --> E4[LanguagesTab]
    end
```

### 2. Flux de données et signaux

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant UI as Interface Utilisateur
    participant C as TranslationCoordinator
    participant AR as AudioRecordingService
    participant SR as SpeechRecognitionService
    participant TS as TranslationService
    participant TTS as SpeechSynthesisService
    participant AS as AppState
    
    U->>UI: Appuie sur Enregistrement
    UI->>C: startTranslationSession()
    C->>AS: currentState = .recording
    C->>AR: startRecording()
    AR-->>AR: Capture audio
    AR-->>SR: Fournit buffer audio
    
    Note over AR,SR: Détection de silence
    AR-->>C: Notification de silence
    C->>SR: performRecognition()
    SR-->>SR: Traitement audio
    SR-->>C: Notification de reconnaissance terminée
    
    C->>TS: translate(text, from, to)
    TS-->>TS: Processus de traduction
    TS-->>C: Résultat de traduction
    
    C->>AS: addMessage(original, translated, fromSource)
    C->>TTS: speak(translatedText, language)
    TTS-->>U: Synthèse vocale audible
    AS-->>UI: Mise à jour de l'interface
    UI-->>U: Affiche la traduction
```

### 3. Structure des services

```mermaid
classDiagram
    class TranslationCoordinator {
        -audioRecordingService: AudioRecordingService
        -speechRecognitionService: SpeechRecognitionService
        -translationService: TranslationService
        -speechSynthesisService: SpeechSynthesisService
        -appState: AppState
        -modelManager: ModelManager
        -preferencesManager: PreferencesManager
        +startTranslationSession()
        +stopTranslationSession()
        -handleRecognitionResult()
        -configureServices()
    }
    
    class AudioRecordingService {
        -audioSession: AVAudioSession
        -audioEngine: AVAudioEngine
        -inputNode: AVAudioInputNode
        +isRecording: Bool
        +currentAudioLevel: Float
        +isSilence: Bool
        +startRecording()
        +stopRecording()
        +configureSilenceDetection()
        -updateAudioLevel()
        -detectSilence()
    }
    
    class SpeechRecognitionService {
        -audioRecorder: AudioRecordingService
        -modelManager: ModelManager
        +state: RecognitionState
        +currentResult: RecognitionResult
        +configure(model: ModelInfo)
        +startRecognition()
        +stopRecognition()
        -processAudioBuffer()
        -performRecognition()
    }
    
    class TranslationService {
        -modelManager: ModelManager
        +state: TranslationState
        +lastResult: TranslationResult
        +translate(text, from, to) -> Result
        -generateSimulatedTranslation()
    }
    
    class SpeechSynthesisService {
        -synthesizer: AVSpeechSynthesizer
        -utteranceQueue: [AVSpeechUtterance]
        +isSpeaking: Bool
        +speak(text, language)
        +stopSpeaking()
        +setVolume()
        -createUtterance()
        -processNextUtterance()
    }
    
    TranslationCoordinator --> AudioRecordingService
    TranslationCoordinator --> SpeechRecognitionService
    TranslationCoordinator --> TranslationService
    TranslationCoordinator --> SpeechSynthesisService
```

### 4. Gestion des états et données

```mermaid
erDiagram
    AppState ||--o{ ConversationMessage : contains
    AppState ||--o{ ApplicationState : has
    AppState ||--|| Language : has-source
    AppState ||--|| Language : has-target
    
    ModelManager ||--o{ ModelInfo : manages
    ModelManager ||--|| ModelInfo : selected-speech
    ModelManager ||--|| ModelInfo : selected-translation
    
    PreferencesManager ||--o{ Setting : stores
    
    ModelInfo ||--o{ Language : supports
    ModelInfo ||--|| ModelType : has-type
    
    ConversationMessage {
        UUID id
        String original
        String translated
        Date timestamp
        Boolean fromSource
    }
    
    ApplicationState {
        Enum state
    }
    
    Language {
        String code
        String displayName
    }
    
    ModelInfo {
        UUID id
        String name
        ModelType type
        Int sizeInMB
        URL downloadURL
        String version
    }
    
    ModelType {
        Enum type
    }
    
    Setting {
        String key
        Any value
    }
```

## 📍 Processus clés

### 1. Traitement audio et reconnaissance vocale

```mermaid
graph TB
    A["Microphone"] -->|"Signal audio brut"| B["AudioRecordingService"]
    B -->|"Tampons audio"| C["Détecteur d'activité vocale"]
    B -->|"Niveau audio"| D["Indicateur visuel"]
    
    C -->|"Silence détecté"| E["SpeechRecognitionService"]
    C -->|"Parole en cours"| F["Continuer l'enregistrement"]
    
    E -->|"Audio accumulé"| G["Whisper.cpp"]
    G -->|"Texte transcrit"| H["Résultat de reconnaissance"]
    
    subgraph "Modèle Whisper"
        G
    end
```

### 2. Traduction et synthèse vocale

```mermaid
graph TB
    A["Texte reconnu"] -->|"Source + cible"| B["TranslationService"]
    B -->|"Demande de traduction"| C["LibreTranslate"]
    C -->|"Texte traduit"| D["Résultat de traduction"]
    
    D -->|"Texte à synthétiser"| E["SpeechSynthesisService"]
    E -->|"Configuration d'énoncé"| F["AVSpeechSynthesizer"]
    F -->|"Audio synthétisé"| G["Haut-parleurs"]
    
    subgraph "Modèles de traduction"
        C
    end
```

### 3. Cycle de vie des données

```mermaid
stateDiagram-v2
    [*] --> InputAudio
    InputAudio --> Transcription: Reconnaissance vocale
    Transcription --> Translation: Traduction
    Translation --> Display: Affichage
    Translation --> OutputAudio: Synthèse vocale
    
    Display --> Storage: Si historique activé
    Display --> [*]: Si historique désactivé
    
    OutputAudio --> [*]
    Storage --> [*]: Après période de rétention
```

## 💯 Gestion des performances

### 1. Utilisation de la mémoire

```mermaid
pie title "Répartition de l'utilisation mémoire"
    "Modèle de reconnaissance vocale" : 1500
    "Modèles de traduction" : 900
    "Tampon audio" : 50
    "Interface utilisateur" : 150
    "Autres composants" : 100
```

### 2. Stratégie d'optimisation

```mermaid
graph TD
    A["Modèles complets"] -->|"Quantification"| B["Modèles optimisés"]
    B -->|"Réduction de précision"| C["Modèles légers"]
    
    D["Chargement à la demande"] -->|"CPU"| E["Exécution standard"]
    D -->|"GPU"| F["Exécution accélérée"]
    
    G["Détection dynamique"] -->|"Ressources disponibles"| H["Adaptation"]
    H -->|"Haute disponibilité"| I["Haute qualité"]
    H -->|"Ressources limitées"| J["Mode économique"]
```

## 🔒 Sécurité et confidentialité

```mermaid
flowchart TD
    A["Données utilisateur"] --> B{"Traitement"}
    B -->|"100% local"| C["Aucune connexion internet"]
    
    D["Audio enregistré"] --> E{"Stockage"}
    E -->|"Mémoire temporaire"| F["Effacé après traitement"]
    
    G["Historique des conversations"] --> H{"Contrôles utilisateur"}
    H -->|"Désactivation possible"| I["Aucun stockage"]
    H -->|"Stockage limité"| J["Effacé automatiquement"]
    
    K["Modèles téléchargés"] --> L{"Vérification"}
    L -->|"Intégrité"| M["Checksums SHA-256"]
```

## 📦 Structure des packages et dépendances

```mermaid
graph TB
    subgraph "MacLocalTranslator"
        A["Main App"] -->|"dépend de"| B["Models"]
        A -->|"dépend de"| C["Views"]
        A -->|"dépend de"| D["Services"]
        A -->|"dépend de"| E["Utils"]
        
        D -->|"dépend de"| B
        C -->|"dépend de"| B
    end
    
    subgraph "Dépendances externes"
        F["Whisper.cpp"] --> D
        G["LibreTranslate Swift"] --> D
        H["Swift Algorithms"] --> B
    end
```

## 📄 Modèles de fichiers et stockage

```mermaid
flowchart TD
    subgraph "~/Library/Application Support/MacLocalTranslator"
        A["models/"] --> A1["speech/"]
        A --> A2["translation/"]
        B["logs/"] --> B1["translator_YYYY-MM-DD.log"]
        C["history/"] --> C1["conversation_ID.json"]
        D["preferences.plist"]
    end
    
    subgraph "Format des données"
        E["Modèle de reconnaissance vocale"] --> E1["Format binaire Whisper.cpp"]
        F["Modèle de traduction"] --> F1["Format ONNX/binaire"]
        G["Historique"] --> G1["JSON avec horodatage"]
        H["Préférences"] --> H1["PropertyList"]
    end
```

## 📊 Métriques et surveillance

```mermaid
dashboard
    title "Tableau de bord de performances"
    
    graph CPU "Utilisation CPU"
        title "Utilisation CPU par composant"
        x-axis "Temps (s)"
        y-axis "% CPU"
        bar "Reconnaissance"
        bar "Traduction"
        bar "Interface"
        bar "Audio"
    
    graph Memory "Utilisation mémoire"
        title "Consommation de RAM"
        x-axis "Temps (s)"
        y-axis "Mo"
        line "Total"
        line "Modèles"
        line "Données"
        line "Cache"
    
    graph Response "Temps de réponse"
        title "Latence par étape (ms)"
        x-axis "Composant"
        y-axis "Temps (ms)"
        bar "VAD"
        bar "Reconnaissance"
        bar "Traduction"
        bar "Synthèse"
```

## 🛠️ Évolution et extensibilité

```mermaid
mindmap
    root((Mac Local Translator))
        Extensions futures
            Traduction de documents
                PDF
                Word
                Images
            Nouvelles langues
                Asiatiques
                    Chinois
                    Japonais
                    Coréen
                Arabes
                    Arabe standard
                    Dialectes régionaux
            Intégration système
                Services macOS
                Raccourcis Siri
                Menu barre d'état
        Améliorations techniques
            IA avéricée
                Modèles transformers compacts
                Neural Engine optimization
            Performances
                GPU acceleration
                Multi-threading avancé
            Interface utilisateur
                Mode présentation
                Thèmes personnalisables
                Animations fluides
```

---

<p align="center">
  <b>Vue d'ensemble technique de Mac Local Translator</b><br>
  Ce document s'adresse aux développeurs et architectes travaillant sur le projet
</p>