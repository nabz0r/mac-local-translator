//
//  PreferencesManager.swift
//  MacLocalTranslator
//
//  Gère les préférences de l'application
//

import Foundation
import Combine

class PreferencesManager: ObservableObject {
    // MARK: - Clés de préférences
    
    /// Enum pour les clés de préférences, avec valeurs String
    enum PreferenceKey: String {
        case sourceLanguage = "sourceLanguage"
        case targetLanguage = "targetLanguage"
        case selectedSpeechModel = "selectedSpeechModel"
        case selectedTranslationModel = "selectedTranslationModel"
        case silenceThreshold = "silenceThreshold"
        case silenceDuration = "silenceDuration"
        case outputVolume = "outputVolume"
        case saveHistory = "saveHistory"
        case historyRetentionDays = "historyRetentionDays"
        case useManualMode = "useManualMode"
        case fontSize = "fontSize"
        case useDarkMode = "useDarkMode"
    }
    
    // MARK: - Propriétés publiées
    
    /// Niveau de seuil de silence pour la détection de fin de parole (0.0 - 1.0)
    @Published var silenceThreshold: Float {
        didSet {
            save(PreferenceKey.silenceThreshold.rawValue, value: silenceThreshold)
        }
    }
    
    /// Durée de silence nécessaire pour considérer qu'une personne a fini de parler (en secondes)
    @Published var silenceDuration: Double {
        didSet {
            save(PreferenceKey.silenceDuration.rawValue, value: silenceDuration)
        }
    }
    
    /// Volume de sortie pour la synthèse vocale (0.0 - 1.0)
    @Published var outputVolume: Float {
        didSet {
            save(PreferenceKey.outputVolume.rawValue, value: outputVolume)
        }
    }
    
    /// Indique si l'historique des conversations doit être enregistré
    @Published var saveHistory: Bool {
        didSet {
            save(PreferenceKey.saveHistory.rawValue, value: saveHistory)
        }
    }
    
    /// Nombre de jours pendant lesquels conserver l'historique
    @Published var historyRetentionDays: Int {
        didSet {
            save(PreferenceKey.historyRetentionDays.rawValue, value: historyRetentionDays)
        }
    }
    
    /// Indique si le mode manuel est activé (plutôt que la détection automatique)
    @Published var useManualMode: Bool {
        didSet {
            save(PreferenceKey.useManualMode.rawValue, value: useManualMode)
        }
    }
    
    /// Taille de police pour l'interface
    @Published var fontSize: Int {
        didSet {
            save(PreferenceKey.fontSize.rawValue, value: fontSize)
        }
    }
    
    /// Indique si le mode sombre est activé
    @Published var useDarkMode: Bool {
        didSet {
            save(PreferenceKey.useDarkMode.rawValue, value: useDarkMode)
        }
    }
    
    // MARK: - Initialisation
    
    init() {
        // Chargement des préférences avec valeurs par défaut
        self.silenceThreshold = UserDefaults.standard.float(forKey: PreferenceKey.silenceThreshold.rawValue, defaultValue: 0.1)
        self.silenceDuration = UserDefaults.standard.double(forKey: PreferenceKey.silenceDuration.rawValue, defaultValue: 1.5)
        self.outputVolume = UserDefaults.standard.float(forKey: PreferenceKey.outputVolume.rawValue, defaultValue: 0.8)
        self.saveHistory = UserDefaults.standard.bool(forKey: PreferenceKey.saveHistory.rawValue, defaultValue: true)
        self.historyRetentionDays = UserDefaults.standard.integer(forKey: PreferenceKey.historyRetentionDays.rawValue, defaultValue: 30)
        self.useManualMode = UserDefaults.standard.bool(forKey: PreferenceKey.useManualMode.rawValue, defaultValue: false)
        self.fontSize = UserDefaults.standard.integer(forKey: PreferenceKey.fontSize.rawValue, defaultValue: 14)
        self.useDarkMode = UserDefaults.standard.bool(forKey: PreferenceKey.useDarkMode.rawValue, defaultValue: false)
    }
    
    // MARK: - Méthodes de sauvegarde
    
    /// Sauvegarde une valeur dans les préférences
    private func save<T>(_ key: String, value: T) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    /// Réinitialise toutes les préférences aux valeurs par défaut
    func resetToDefaults() {
        silenceThreshold = 0.1
        silenceDuration = 1.5
        outputVolume = 0.8
        saveHistory = true
        historyRetentionDays = 30
        useManualMode = false
        fontSize = 14
        useDarkMode = false
    }
}

// MARK: - Extensions

extension UserDefaults {
    /// Récupère une valeur float avec une valeur par défaut
    func float(forKey key: String, defaultValue: Float) -> Float {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return self.float(forKey: key)
    }
    
    /// Récupère une valeur double avec une valeur par défaut
    func double(forKey key: String, defaultValue: Double) -> Double {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return self.double(forKey: key)
    }
    
    /// Récupère une valeur booléenne avec une valeur par défaut
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return self.bool(forKey: key)
    }
    
    /// Récupère une valeur entière avec une valeur par défaut
    func integer(forKey key: String, defaultValue: Int) -> Int {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return self.integer(forKey: key)
    }
}