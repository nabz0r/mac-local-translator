//
//  AppState.swift
//  MacLocalTranslator
//
//  Gère l'état global de l'application et les données partagées
//

import Foundation
import Combine

class AppState: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// État actuel de l'application
    @Published var currentState: ApplicationState = .idle
    
    /// Langue source sélectionnée
    @Published var sourceLanguage: Language = .french
    
    /// Langue cible sélectionnée
    @Published var targetLanguage: Language = .english
    
    /// Liste des messages de la conversation
    @Published var conversationMessages: [ConversationMessage] = []
    
    /// Indicateur d'activité de traduction
    @Published var isTranslating: Bool = false
    
    /// Niveau audio actuel (pour l'indicateur visuel)
    @Published var currentAudioLevel: Float = 0.0
    
    // MARK: - Propriétés privées
    
    /// Gestionnaires d'annulation pour les tâches asynchrones
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialisation
    
    init() {
        // Chargement des préférences utilisateur
        loadUserPreferences()
    }
    
    // MARK: - Méthodes publiques
    
    /// Démarre une nouvelle session de traduction
    func startTranslationSession() {
        guard currentState != .recording else { return }
        
        currentState = .recording
        // Initialiser les services nécessaires ici
    }
    
    /// Arrête la session de traduction en cours
    func stopTranslationSession() {
        guard currentState == .recording else { return }
        
        currentState = .idle
        // Nettoyer les ressources ici
    }
    
    /// Inverse les langues source et cible
    func switchLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
    }
    
    /// Ajoute un nouveau message à la conversation
    func addMessage(original: String, translated: String, fromSource: Bool) {
        let newMessage = ConversationMessage(
            id: UUID(),
            original: original,
            translated: translated,
            timestamp: Date(),
            fromSource: fromSource
        )
        
        conversationMessages.append(newMessage)
    }
    
    /// Efface l'historique de la conversation
    func clearConversation() {
        conversationMessages = []
    }
    
    // MARK: - Méthodes privées
    
    /// Charge les préférences de l'utilisateur depuis le stockage
    private func loadUserPreferences() {
        // Implémentation à venir
    }
}

// MARK: - Types de données

/// États possibles de l'application
enum ApplicationState {
    case idle        // En attente, prêt à démarrer
    case recording   // Enregistrement audio en cours
    case processing  // Traitement de l'audio/traduction
    case error       // État d'erreur
}

/// Langues supportées par l'application
enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"
    case spanish = "es"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .french: return "Français"
        case .spanish: return "Español"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        }
    }
}

/// Structure représentant un message dans la conversation
struct ConversationMessage: Identifiable {
    let id: UUID
    let original: String
    let translated: String
    let timestamp: Date
    let fromSource: Bool  // true si de la langue source, false si de la langue cible
}
