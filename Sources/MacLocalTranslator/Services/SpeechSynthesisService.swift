//
//  SpeechSynthesisService.swift
//  MacLocalTranslator
//
//  Service responsable de la synthèse vocale (texte vers parole)
//

import Foundation
import AVFoundation
import Combine

class SpeechSynthesisService: NSObject, ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Indique si la synthèse vocale est en cours
    @Published var isSpeaking: Bool = false
    
    /// Erreur actuelle si présente
    @Published var synthesisError: Error?
    
    // MARK: - Propriétés privées
    
    /// Synthétiseur vocal
    private let synthesizer = AVSpeechSynthesizer()
    
    /// Volume de la parole synthétisée
    private var volume: Float = 0.8
    
    /// File d'attente des énoncés à synthétiser
    private var utteranceQueue: [AVSpeechUtterance] = []
    
    /// File d'attente de travail sérielle pour la synthèse
    private let speechQueue = DispatchQueue(label: "com.maclocaltranslator.speechsynthesis")
    
    // MARK: - Initialisation
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Configuration
    
    /// Configure le volume de sortie
    func setVolume(_ volume: Float) {
        self.volume = max(0.0, min(1.0, volume))
    }
    
    // MARK: - Méthodes publiques
    
    /// Synthétise un texte en parole dans la langue spécifiée
    func speak(text: String, in language: Language) {
        guard !text.isEmpty else { return }
        
        // Création de l'énoncé
        let utterance = createUtterance(text: text, language: language)
        
        // Ajout à la file d'attente
        speechQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.utteranceQueue.append(utterance)
            
            // Si le synthétiseur n'est pas déjà en train de parler, démarrer la synthèse
            if !self.isSpeaking {
                self.processNextUtterance()
            }
        }
    }
    
    /// Arrête la synthèse vocale en cours
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        
        speechQueue.async { [weak self] in
            self?.utteranceQueue.removeAll()
        }
    }
    
    // MARK: - Méthodes privées
    
    /// Crée un énoncé à partir d'un texte et d'une langue
    private func createUtterance(text: String, language: Language) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        
        // Définition de la langue
        switch language {
        case .english:
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        case .french:
            utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        case .spanish:
            utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        case .german:
            utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        case .italian:
            utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        case .portuguese:
            utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        }
        
        // Configuration des paramètres de l'énoncé
        utterance.volume = volume
        utterance.rate = 0.5  // Vitesse moyenne (0.0-1.0)
        utterance.pitchMultiplier = 1.0  // Hauteur normale
        
        return utterance
    }
    
    /// Traite le prochain énoncé dans la file d'attente
    private func processNextUtterance() {
        speechQueue.async { [weak self] in
            guard let self = self, !self.utteranceQueue.isEmpty else { return }
            
            // Récupérer et retirer le premier énoncé de la file
            let utterance = self.utteranceQueue.removeFirst()
            
            // Mise à jour de l'état sur le thread principal
            DispatchQueue.main.async {
                self.isSpeaking = true
            }
            
            // Démarrer la synthèse sur le thread principal
            DispatchQueue.main.async {
                self.synthesizer.speak(utterance)
            }
        }
    }
}

// MARK: - Extensions

extension SpeechSynthesisService: AVSpeechSynthesizerDelegate {
    /// Notifie que le synthétiseur a terminé de prononcer un énoncé
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speechQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Vérifier s'il y a d'autres énoncés dans la file d'attente
            if self.utteranceQueue.isEmpty {
                DispatchQueue.main.async {
                    self.isSpeaking = false
                }
            } else {
                // Traiter le prochain énoncé
                self.processNextUtterance()
            }
        }
    }
    
    /// Notifie que le synthétiseur a rencontré une erreur
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }
}