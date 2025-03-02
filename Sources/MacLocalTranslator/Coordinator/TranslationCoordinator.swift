//
//  TranslationCoordinator.swift
//  MacLocalTranslator
//
//  Coordonne les interactions entre les différents services de l'application
//

import Foundation
import Combine

class TranslationCoordinator: ObservableObject {
    // MARK: - Services gérés
    
    /// Service d'enregistrement audio
    private let audioRecordingService: AudioRecordingService
    
    /// Service de reconnaissance vocale
    private let speechRecognitionService: SpeechRecognitionService
    
    /// Service de traduction
    private let translationService: TranslationService
    
    /// Service de synthèse vocale
    private let speechSynthesisService: SpeechSynthesisService
    
    // MARK: - Références aux gestionnaires
    
    /// État global de l'application
    private let appState: AppState
    
    /// Gestionnaire des modèles
    private let modelManager: ModelManager
    
    /// Gestionnaire des préférences
    private let preferencesManager: PreferencesManager
    
    // MARK: - Propriétés privées
    
    /// Gestionnaires d'annulation pour les souscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialisation
    
    init(appState: AppState, modelManager: ModelManager, preferencesManager: PreferencesManager) {
        self.appState = appState
        self.modelManager = modelManager
        self.preferencesManager = preferencesManager
        
        // Initialisation des services
        self.audioRecordingService = AudioRecordingService()
        self.speechRecognitionService = SpeechRecognitionService(audioRecorder: audioRecordingService, modelManager: modelManager)
        self.translationService = TranslationService(modelManager: modelManager)
        self.speechSynthesisService = SpeechSynthesisService()
        
        // Configuration des services
        configureServices()
        
        // Configuration des notifications
        setupNotifications()
    }
    
    // MARK: - Configuration
    
    /// Configure les services avec les paramètres actuels
    private func configureServices() {
        // Configuration de la détection de silence
        audioRecordingService.configureSilenceDetection(
            threshold: preferencesManager.silenceThreshold,
            duration: preferencesManager.silenceDuration
        )
        
        // Configuration du volume de sortie
        speechSynthesisService.setVolume(preferencesManager.outputVolume)
        
        // Configuration des modèles
        speechRecognitionService.configure(model: modelManager.selectedSpeechModel)
    }
    
    // MARK: - Notifications
    
    /// Configure les écouteurs de notifications
    private func setupNotifications() {
        // Notification de reconnaissance vocale terminée
        NotificationCenter.default.publisher(for: .speechRecognitionCompleted)
            .sink { [weak self] notification in
                guard let self = self,
                      let result = notification.userInfo?["result"] as? SpeechRecognitionService.RecognitionResult else {
                    return
                }
                
                // Effectuer la traduction du texte reconnu
                self.handleRecognitionResult(result)
            }
            .store(in: &cancellables)
        
        // Observer les changements de préférences
        preferencesManager.objectWillChange
            .sink { [weak self] _ in
                self?.configureServices()
            }
            .store(in: &cancellables)
        
        // Observer les changements de modèles
        modelManager.objectWillChange
            .sink { [weak self] _ in
                self?.speechRecognitionService.configure(model: self?.modelManager.selectedSpeechModel)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Contrôle du flux de traduction
    
    /// Démarre une session de traduction
    func startTranslationSession() {
        guard appState.currentState != .recording else { return }
        
        // Mise à jour de l'état
        appState.currentState = .recording
        
        // Démarrage de la reconnaissance vocale
        speechRecognitionService.startRecognition()
    }
    
    /// Arrête la session de traduction en cours
    func stopTranslationSession() {
        guard appState.currentState == .recording else { return }
        
        // Arrêt de la reconnaissance vocale
        speechRecognitionService.stopRecognition()
        
        // Mise à jour de l'état
        appState.currentState = .idle
    }
    
    // MARK: - Gestion des résultats
    
    /// Gère le résultat de la reconnaissance vocale
    private func handleRecognitionResult(_ result: SpeechRecognitionService.RecognitionResult) {
        // Détection de la langue source réelle (pourrait être différente de celle configurée)
        let detectedSourceLanguage = result.language
        let targetLanguage = appState.targetLanguage
        
        // Signaler le traitement en cours
        appState.isTranslating = true
        appState.currentState = .processing
        
        // Traduire le texte reconnu
        Task {
            let translationResult = await translationService.translate(
                text: result.text,
                from: detectedSourceLanguage,
                to: targetLanguage
            )
            
            // Traitement du résultat sur le thread principal
            await MainActor.run {
                appState.isTranslating = false
                appState.currentState = .idle
                
                switch translationResult {
                case .success(let translation):
                    // Ajouter le message à la conversation
                    appState.addMessage(
                        original: translation.sourceText,
                        translated: translation.translatedText,
                        fromSource: true
                    )
                    
                    // Lire la traduction à haute voix
                    speechSynthesisService.speak(
                        text: translation.translatedText,
                        in: translation.targetLanguage
                    )
                    
                case .failure(let error):
                    // Gérer l'erreur (dans une implémentation réelle, on afficherait un message d'erreur)
                    print("Erreur de traduction: \(error.localizedDescription)")
                    appState.currentState = .error
                }
            }
        }
    }
}
