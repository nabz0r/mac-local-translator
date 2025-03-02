//
//  AudioRecordingService.swift
//  MacLocalTranslator
//
//  Service responsable de l'enregistrement audio via le microphone
//

import Foundation
import AVFoundation
import Combine

class AudioRecordingService: NSObject, ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Indique si l'enregistrement est actuellement actif
    @Published var isRecording: Bool = false
    
    /// Niveau audio actuel (pour l'indicateur visuel)
    @Published var currentAudioLevel: Float = 0.0
    
    /// Indique si un silence est détecté
    @Published var isSilence: Bool = true
    
    /// Erreur actuelle si présente
    @Published var recordingError: Error?
    
    // MARK: - Propriétés privées
    
    /// Session audio
    private var audioSession: AVAudioSession!
    
    /// Engine audio
    private var audioEngine: AVAudioEngine!
    
    /// Noeud d'entrée audio
    private var inputNode: AVAudioInputNode!
    
    /// Gestionnaire des données audio
    private var audioBufferHandler: ((AVAudioPCMBuffer, AVAudioTime) -> Void)?
    
    /// Seuil de silence
    private var silenceThreshold: Float = 0.1
    
    /// Durée de silence requise pour considérer qu'une personne a terminé de parler
    private var silenceDuration: Double = 1.5
    
    /// Timer de détection de silence
    private var silenceTimer: Timer?
    
    /// Dernier moment où un son a été détecté
    private var lastSoundDetectedTime: Date?
    
    // MARK: - Initialisation
    
    override init() {
        super.init()
        setupAudioSession()
        setupAudioEngine()
    }
    
    // MARK: - Configuration
    
    /// Configure les paramètres de détection de silence
    func configureSilenceDetection(threshold: Float, duration: Double) {
        self.silenceThreshold = threshold
        self.silenceDuration = duration
    }
    
    // MARK: - Contrôle de l'enregistrement
    
    /// Démarre l'enregistrement audio
    func startRecording() throws {
        guard !isRecording else { return }
        
        // Si le moteur audio est déjà en cours d'exécution, l'arrêter d'abord
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Configuration du format audio
        let format = inputNode.outputFormat(forBus: 0)
        
        // Installation du tap pour recevoir les données audio
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            guard let self = self else { return }
            
            // Mesure du niveau audio
            self.updateAudioLevel(buffer: buffer)
            
            // Détection de silence
            self.detectSilence()
            
            // Transmission du buffer au gestionnaire
            self.audioBufferHandler?(buffer, time)
        }
        
        // Démarrage du moteur audio
        try audioEngine.start()
        
        isRecording = true
        recordingError = nil
    }
    
    /// Arrête l'enregistrement audio
    func stopRecording() {
        guard isRecording else { return }
        
        // Suppression du tap d'entrée
        inputNode.removeTap(onBus: 0)
        
        // Arrêt du moteur audio
        audioEngine.stop()
        
        isRecording = false
        lastSoundDetectedTime = nil
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
    
    /// Définit le gestionnaire de données audio
    func setAudioBufferHandler(_ handler: @escaping (AVAudioPCMBuffer, AVAudioTime) -> Void) {
        self.audioBufferHandler = handler
    }
    
    // MARK: - Méthodes privées
    
    /// Configure la session audio
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            recordingError = error
        }
    }
    
    /// Configure le moteur audio
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
    }
    
    /// Met à jour le niveau audio actuel
    private func updateAudioLevel(buffer: AVAudioPCMBuffer) {
        // Calcul du niveau audio RMS (Root Mean Square)
        var rms: Float = 0.0
        
        // Pointer vers les données du buffer
        let channelData = buffer.floatChannelData?[0]
        
        if let channelData = channelData {
            let frameLength = Int(buffer.frameLength)
            
            // Calcul de la somme des carrés
            for i in 0..<frameLength {
                rms += channelData[i] * channelData[i]
            }
            
            // Moyenne et racine carrée
            rms = sqrt(rms / Float(frameLength))
            
            // Mise à jour du niveau audio sur le thread principal
            DispatchQueue.main.async {
                self.currentAudioLevel = rms
                
                // Déterminer si c'est un silence
                if rms > self.silenceThreshold {
                    self.lastSoundDetectedTime = Date()
                    self.isSilence = false
                }
            }
        }
    }
    
    /// Détecte les périodes de silence
    private func detectSilence() {
        // Si nous avons détecté un son récemment
        if let lastSoundTime = lastSoundDetectedTime {
            // Détecter si le silence dure depuis assez longtemps
            let silenceInterval = Date().timeIntervalSince(lastSoundTime)
            
            if silenceInterval >= silenceDuration && !isSilence {
                DispatchQueue.main.async {
                    self.isSilence = true
                    // Notifier du silence prolongé via NotificationCenter
                    NotificationCenter.default.post(
                        name: .prolongedSilenceDetected,
                        object: nil
                    )
                }
            }
        }
    }
    
    // MARK: - Nettoyage
    
    deinit {
        stopRecording()
        try? audioSession.setActive(false)
    }
}

// MARK: - Extensions

extension Notification.Name {
    /// Notification envoyée lorsqu'un silence prolongé est détecté après la parole
    static let prolongedSilenceDetected = Notification.Name("prolongedSilenceDetected")
}