//
//  SpeechRecognitionService.swift
//  MacLocalTranslator
//
//  Service responsable de la reconnaissance vocale via Whisper stub
//

import Foundation
import Combine
import AVFAudio

class SpeechRecognitionService: ObservableObject {
    // MARK: - Types
    
    /// Résultat de la reconnaissance vocale
    struct RecognitionResult {
        let text: String
        let language: Language
        let confidence: Float
        let duration: TimeInterval
    }
    
    /// États possibles du service
    enum RecognitionState: Equatable {
        case idle
        case initializing
        case recording
        case recognizing
        case failed(String) // Utilise String au lieu de Error pour permettre la conformité à Equatable
        
        // Implémentation manuelle de '==' pour les types avec valeurs associées
        static func == (lhs: RecognitionState, rhs: RecognitionState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.initializing, .initializing),
                 (.recording, .recording),
                 (.recognizing, .recognizing):
                return true
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    // MARK: - Propriétés publiées
    
    /// État actuel du service
    @Published var state: RecognitionState = .idle
    
    /// Résultat actuel de la reconnaissance
    @Published var currentResult: RecognitionResult?
    
    /// Indique si le service est actif
    @Published var isActive: Bool = false
    
    // MARK: - Propriétés privées
    
    /// Service d'enregistrement audio
    private var audioRecorder: AudioRecordingService
    
    /// Gestionnaire des modèles
    private var modelManager: ModelManager
    
    /// Modèle Whisper (stub)
    private var whisperModel: WhisperModel?
    
    /// Buffer audio accumulant les données pendant l'enregistrement
    private var audioBuffer: AVAudioPCMBuffer?
    
    /// Format audio utilisé pour la reconnaissance
    private var audioFormat: AVAudioFormat?
    
    /// Gestionnaires d'annulation pour les tâches asynchrones
    private var cancellables = Set<AnyCancellable>()
    
    /// Queue de traitement pour la reconnaissance vocale
    private let processingQueue = DispatchQueue(label: "com.maclocaltranslator.speechrecognition", qos: .userInitiated)
    
    // MARK: - Initialisation
    
    init(audioRecorder: AudioRecordingService, modelManager: ModelManager) {
        self.audioRecorder = audioRecorder
        self.modelManager = modelManager
        
        setupNotifications()
        
        // Initialiser le modèle Whisper (stub)
        self.whisperModel = WhisperModel()
    }
    
    // MARK: - Configuration
    
    /// Configure le service avec un modèle spécifique
    func configure(model: ModelInfo?) {
        guard let model = model, model.type == .speech else {
            state = .failed("Modèle de reconnaissance vocale non valide")
            return
        }
        
        state = .initializing
        
        // Simulation d'initialisation du modèle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.state = .idle
        }
    }
    
    // MARK: - Contrôle du service
    
    /// Démarre la reconnaissance vocale
    func startRecognition() {
        guard state == .idle else { return }
        
        // Configuration du gestionnaire de buffer audio
        audioRecorder.setAudioBufferHandler { [weak self] buffer, time in
            self?.processAudioBuffer(buffer, time: time)
        }
        
        // Démarrage de l'enregistrement audio
        do {
            try audioRecorder.startRecording()
            state = .recording
            isActive = true
        } catch {
            state = .failed(error.localizedDescription)
            isActive = false
        }
    }
    
    /// Arrête la reconnaissance vocale
    func stopRecognition() {
        guard isActive else { return }
        
        audioRecorder.stopRecording()
        
        // Traiter le dernier buffer audio si nécessaire
        if state == .recording {
            performRecognition()
        }
        
        state = .idle
        isActive = false
    }
    
    // MARK: - Traitement audio
    
    /// Traite un buffer audio reçu du microphone
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        // Dans une implémentation réelle, on accumulerait les données audio dans le buffer
        // Pour cette version prototype, on ne fait que stocker la référence au buffer actuel
        self.audioBuffer = buffer
        self.audioFormat = buffer.format
    }
    
    /// Effectue la reconnaissance vocale sur l'audio enregistré
    private func performRecognition() {
        guard let _ = audioBuffer else { return }
        
        state = .recognizing
        
        // Dans une implémentation réelle, on traiterait l'audio avec Whisper.cpp
        // Pour cette version prototype, on simule une reconnaissance
        
        // Simulation d'un traitement asynchrone
        processingQueue.async { [weak self] in
            // Simulation d'un délai de traitement
            Thread.sleep(forTimeInterval: 1.0)
            
            // Utiliser le modèle stub pour générer une transcription
            let transcribedText = self?.whisperModel?.transcribe(Data()) ?? "Bonjour"
            
            // Création d'un résultat simulé
            let simulatedResult = RecognitionResult(
                text: transcribedText,
                language: .french,
                confidence: 0.92,
                duration: 2.5
            )
            
            // Mise à jour sur le thread principal
            DispatchQueue.main.async {
                self?.currentResult = simulatedResult
                self?.state = .idle
                
                // Notifier que la reconnaissance est terminée
                NotificationCenter.default.post(
                    name: .speechRecognitionCompleted,
                    object: nil,
                    userInfo: ["result": simulatedResult]
                )
            }
        }
    }
    
    // MARK: - Notifications
    
    /// Configure les écouteurs de notifications
    private func setupNotifications() {
        // Écouter la notification de silence prolongé
        NotificationCenter.default.publisher(for: .prolongedSilenceDetected)
            .sink { [weak self] _ in
                guard let self = self, self.state == .recording else { return }
                
                // Une période de silence a été détectée, lancer la reconnaissance
                self.performRecognition()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Extensions

extension Notification.Name {
    /// Notification envoyée lorsque la reconnaissance vocale est terminée
    static let speechRecognitionCompleted = Notification.Name("speechRecognitionCompleted")
}