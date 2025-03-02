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
    
    private enum PreferenceKeys {
        static let sourceLanguage = "sourceLanguage"
        static let targetLanguage = "targetLanguage"
        static let selectedSpeechModel = "selectedSpeechModel"
        static let selectedTranslationModel = "selectedTranslationModel"
        static let silenceThreshold = "silenceThreshold"
        static let silenceDuration = "silenceDuration"
        static let outputVolume = "outputVolume"
        static let saveHistory = "saveHistory"
        static let historyRetentionDays = "historyRetentionDays"
        static let useManualMode = "useManualMode"
        static let fontSize = "fontSize"
        static let useDarkMode = "useDarkMode"
    }
    
    // MARK: - Propriétés publiées
    
    /// Niveau de seuil de silence pour la détection de fin de parole (0.0 - 1.0)
    @Published var silenceThreshold: Float {
        didSet {
            save(.silenceThreshold, value: silenceThreshold)
        }
    }
    
    /// Durée de silence nécessaire pour considérer qu'une personne a fini de parler (en secondes)
    @Published var silenceDuration: Double {
        didSet {
            save(.silenceDuration, value: silenceDuration)
        }
    }
    
    /// Volume de sortie pour la synthèse vocale (0.0 - 1.0)
    @Published var outputVolume: Float {
        didSet {
            save(.outputVolume, value: outputVolume)
        }
    }
    
    /// Indique si l'historique des conversations doit être enregistré
    @Published var saveHistory: Bool {
        didSet {
            save(.saveHistory, value: saveHistory)
        }
    }
    
    /// Nombre de jours pendant lesquels conserver l'historique
    @Published var historyRetentionDays: Int {
        didSet {
            save(.historyRetentionDays, value: historyRetentionDays)
        }
    }
    
    /// Indique si le mode manuel est activé (plutôt que la détection automatique)
    @Published var useManualMode: Bool {
        didSet {
            save(.useManualMode, value: useManualMode)
        }
    }
    
    /// Taille de police pour l'interface
    @Published var fontSize: Int {
        didSet {
            save(.fontSize, value: fontSize)
        }
    }
    
    /// Indique si le mode sombre est activé
    @Published var useDarkMode: Bool {
        didSet {
            save(.useDarkMode, value: useDarkMode)
        }
    }
    
    // MARK: - Initialisation
    
    init() {
        // Chargement des préférences avec valeurs par défaut
        self.silenceThreshold = UserDefaults.standard.float(forKey: PreferenceKeys.silenceThreshold, defaultValue: 0.1)
        self.silenceDuration = UserDefaults.standard.double(forKey: PreferenceKeys.silenceDuration, defaultValue: 1.5)
        self.outputVolume = UserDefaults.standard.float(forKey: PreferenceKeys.outputVolume, defaultValue: 0.8)
        self.saveHistory = UserDefaults.standard.bool(forKey: PreferenceKeys.saveHistory, defaultValue: true)
        self.historyRetentionDays = UserDefaults.standard.integer(forKey: PreferenceKeys.historyRetentionDays, defaultValue: 30)
        self.useManualMode = UserDefaults.standard.bool(forKey: PreferenceKeys.useManualMode, defaultValue: false)
        self.fontSize = UserDefaults.standard.integer(forKey: PreferenceKeys.fontSize, defaultValue: 14)
        self.useDarkMode = UserDefaults.standard.bool(forKey: PreferenceKeys.useDarkMode, defaultValue: false)
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