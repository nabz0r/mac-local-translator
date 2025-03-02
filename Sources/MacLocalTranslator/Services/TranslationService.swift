//
//  TranslationService.swift
//  MacLocalTranslator
//
//  Service responsable de la traduction de texte
//

import Foundation
import Combine

class TranslationService: ObservableObject {
    // MARK: - Types
    
    /// Résultat de traduction
    struct TranslationResult {
        let sourceText: String
        let translatedText: String
        let sourceLanguage: Language
        let targetLanguage: Language
        let confidence: Float
    }
    
    /// États possibles du service
    enum TranslationState {
        case idle
        case translating
        case completed(TranslationResult)
        case failed(Error)
    }
    
    // MARK: - Propriétés publiées
    
    /// État actuel du service
    @Published var state: TranslationState = .idle
    
    /// Résultat de la dernière traduction
    @Published var lastResult: TranslationResult?
    
    // MARK: - Propriétés privées
    
    /// Gestionnaire des modèles
    private var modelManager: ModelManager
    
    /// Modèles de traduction (stubs)
    private var translationModels: [String: LibreTranslateModel] = [:]
    
    /// Queue de traitement pour la traduction
    private let processingQueue = DispatchQueue(label: "com.maclocaltranslator.translation", qos: .userInitiated)
    
    // MARK: - Initialisation
    
    init(modelManager: ModelManager) {
        self.modelManager = modelManager
        
        // Initialiser les modèles de traduction (stubs)
        self.translationModels = [
            "fr-en": LibreTranslateModel(source: "fr", target: "en"),
            "en-fr": LibreTranslateModel(source: "en", target: "fr"),
            "en-es": LibreTranslateModel(source: "en", target: "es"),
            "es-en": LibreTranslateModel(source: "es", target: "en")
        ]
    }
    
    // MARK: - Méthodes publiques
    
    /// Traduit un texte d'une langue source vers une langue cible
    func translate(text: String, from sourceLanguage: Language, to targetLanguage: Language) async -> Result<TranslationResult, Error> {
        // Vérification que le texte n'est pas vide
        guard !text.isEmpty else {
            let error = NSError(domain: "Translation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Le texte source est vide"])
            await updateState(.failed(error))
            return .failure(error)
        }
        
        // Vérification que les langues sont différentes
        guard sourceLanguage != targetLanguage else {
            // Si les langues sont identiques, retourner le texte original
            let result = TranslationResult(
                sourceText: text,
                translatedText: text,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                confidence: 1.0
            )
            await updateState(.completed(result))
            return .success(result)
        }
        
        // Mise à jour de l'état
        await updateState(.translating)
        
        do {
            // Délai simulé pour le traitement
            try await Task.sleep(nanoseconds: 800_000_000)  // 0.8 seconde
            
            // Trouver le modèle de traduction approprié
            let modelKey = "\(sourceLanguage.rawValue)-\(targetLanguage.rawValue)"
            let translatedText: String
            
            if let model = translationModels[modelKey] {
                translatedText = model.translate(text)
            } else {
                // Utiliser notre générateur de traduction simulée si pas de modèle disponible
                translatedText = generateSimulatedTranslation(text, from: sourceLanguage, to: targetLanguage)
            }
            
            // Création du résultat
            let result = TranslationResult(
                sourceText: text,
                translatedText: translatedText,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                confidence: 0.89
            )
            
            // Mise à jour de l'état et du résultat
            await updateState(.completed(result))
            await updateLastResult(result)
            
            return .success(result)
        } catch {
            await updateState(.failed(error))
            return .failure(error)
        }
    }
    
    // MARK: - Méthodes privées
    
    /// Met à jour l'état du service sur le thread principal
    @MainActor
    private func updateState(_ newState: TranslationState) {
        self.state = newState
    }
    
    /// Met à jour le dernier résultat sur le thread principal
    @MainActor
    private func updateLastResult(_ result: TranslationResult) {
        self.lastResult = result
    }
    
    /// Génère une traduction simulée pour le prototype
    private func generateSimulatedTranslation(_ text: String, from sourceLanguage: Language, to targetLanguage: Language) -> String {
        // Dans une implémentation réelle, on utiliserait un modèle de traduction
        // Pour cette version prototype, on utilise quelques exemples prédéfinis
        
        let translations: [String: [Language: String]] = [
            "Bonjour, comment puis-je vous aider aujourd'hui ?": [
                .english: "Hello, how can I help you today?",
                .spanish: "¡Hola! ¿Cómo puedo ayudarte hoy?",
                .german: "Guten Tag, wie kann ich Ihnen heute helfen?"
            ],
            "Je voudrais réserver une table pour deux personnes ce soir.": [
                .english: "I would like to book a table for two people tonight.",
                .spanish: "Me gustaría reservar una mesa para dos personas esta noche.",
                .german: "Ich möchte heute Abend einen Tisch für zwei Personen reservieren."
            ],
            "Hello, how can I help you today?": [
                .french: "Bonjour, comment puis-je vous aider aujourd'hui ?",
                .spanish: "¡Hola! ¿Cómo puedo ayudarte hoy?",
                .german: "Guten Tag, wie kann ich Ihnen heute helfen?"
            ],
            "I would like to book a table for two people tonight.": [
                .french: "Je voudrais réserver une table pour deux personnes ce soir.",
                .spanish: "Me gustaría reservar una mesa para dos personas esta noche.",
                .german: "Ich möchte heute Abend einen Tisch für zwei Personen reservieren."
            ]
        ]
        
        // Si on trouve une traduction prédéfinie, on l'utilise
        if let languageMap = translations[text], let translation = languageMap[targetLanguage] {
            return translation
        }
        
        // Sinon, on retourne une traduction factice
        return "[Traduction de \"\(text)\" de \(sourceLanguage.displayName) vers \(targetLanguage.displayName)]"
    }
}