//
//  ModelManager.swift
//  MacLocalTranslator
//
//  Gère les modèles de reconnaissance vocale et de traduction
//

import Foundation
import Combine

class ModelManager: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Liste des modèles de reconnaissance vocale disponibles
    @Published var availableSpeechModels: [ModelInfo] = []
    
    /// Liste des modèles de traduction disponibles
    @Published var availableTranslationModels: [ModelInfo] = []
    
    /// Modèle de reconnaissance vocale sélectionné
    @Published var selectedSpeechModel: ModelInfo?
    
    /// Modèle de traduction sélectionné
    @Published var selectedTranslationModel: ModelInfo?
    
    /// Indicateur de téléchargement
    @Published var isDownloadingModel: Bool = false
    
    /// Progression du téléchargement (0.0 - 1.0)
    @Published var downloadProgress: Double = 0.0
    
    /// Erreur actuelle si présente
    @Published var currentError: ModelError?
    
    // MARK: - Propriétés privées
    
    /// Dossier contenant les modèles
    private let modelsDirectory: URL
    
    /// Gestionnaires de téléchargement
    private var downloadTasks: [UUID: URLSessionDownloadTask] = [:]
    
    // MARK: - Initialisation
    
    init() {
        // Détermine le dossier pour stocker les modèles
        let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.modelsDirectory = appSupportDirectory.appendingPathComponent("MacLocalTranslator/models", isDirectory: true)
        
        // Crée le dossier des modèles s'il n'existe pas
        try? FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
        
        // Charge les informations des modèles disponibles
        loadAvailableModels()
    }
    
    // MARK: - Méthodes publiques
    
    /// Vérifie si les modèles requis sont disponibles et les télécharge si nécessaire
    func checkRequiredModels() async {
        // Liste des modèles minimum requis
        let requiredModels = [
            ModelInfo(
                id: UUID(),
                name: "whisper-medium",
                type: .speech,
                languages: Language.allCases,
                sizeInMB: 1500,
                downloadURL: URL(string: "https://example.com/models/whisper-medium.bin")!,
                version: "1.0"
            ),
            ModelInfo(
                id: UUID(),
                name: "libre-translate-en-fr",
                type: .translation,
                languages: [.english, .french],
                sizeInMB: 450,
                downloadURL: URL(string: "https://example.com/models/libre-translate-en-fr.bin")!,
                version: "1.0"
            )
        ]
        
        // Vérifie si chaque modèle requis est disponible
        for requiredModel in requiredModels {
            let isAvailable = isModelAvailable(requiredModel)
            
            if !isAvailable {
                // Si le modèle n'est pas disponible, le télécharger
                await downloadModel(requiredModel)
            }
        }
    }
    
    /// Télécharge un modèle
    func downloadModel(_ model: ModelInfo) async {
        // Impélmentation future - simulée pour le moment
        DispatchQueue.main.async {
            self.isDownloadingModel = true
            self.downloadProgress = 0.0
        }
        
        // Simulation de progression
        for progress in stride(from: 0.0, to: 1.0, by: 0.1) {
            try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconde
            DispatchQueue.main.async {
                self.downloadProgress = progress
            }
        }
        
        DispatchQueue.main.async {
            self.downloadProgress = 1.0
            self.isDownloadingModel = false
            
            // Ajoute le modèle à la liste des modèles disponibles
            if model.type == .speech {
                self.availableSpeechModels.append(model)
                if self.selectedSpeechModel == nil {
                    self.selectedSpeechModel = model
                }
            } else {
                self.availableTranslationModels.append(model)
                if self.selectedTranslationModel == nil {
                    self.selectedTranslationModel = model
                }
            }
        }
    }
    
    /// Supprime un modèle
    func deleteModel(_ model: ModelInfo) {
        let modelPath = modelsDirectory.appendingPathComponent(model.filename)
        
        do {
            try FileManager.default.removeItem(at: modelPath)
            
            // Mettre à jour les listes de modèles disponibles
            if model.type == .speech {
                availableSpeechModels.removeAll { $0.id == model.id }
                if selectedSpeechModel?.id == model.id {
                    selectedSpeechModel = availableSpeechModels.first
                }
            } else {
                availableTranslationModels.removeAll { $0.id == model.id }
                if selectedTranslationModel?.id == model.id {
                    selectedTranslationModel = availableTranslationModels.first
                }
            }
        } catch {
            currentError = .deletionFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Méthodes privées
    
    /// Charge les informations des modèles disponibles
    private func loadAvailableModels() {
        // Pour le prototype, on définit des modèles fictifs
        // Dans une implémentation réelle, on scannerait le dossier des modèles
        
        let speechModel = ModelInfo(
            id: UUID(),
            name: "whisper-small",
            type: .speech,
            languages: Language.allCases,
            sizeInMB: 500,
            downloadURL: URL(string: "https://example.com/models/whisper-small.bin")!,
            version: "1.0"
        )
        
        let translationModel = ModelInfo(
            id: UUID(),
            name: "libre-translate-fr-en",
            type: .translation,
            languages: [.french, .english],
            sizeInMB: 320,
            downloadURL: URL(string: "https://example.com/models/libre-translate-fr-en.bin")!,
            version: "1.0"
        )
        
        availableSpeechModels = [speechModel]
        availableTranslationModels = [translationModel]
        
        selectedSpeechModel = speechModel
        selectedTranslationModel = translationModel
    }
    
    /// Vérifie si un modèle est disponible localement
    private func isModelAvailable(_ model: ModelInfo) -> Bool {
        let modelPath = modelsDirectory.appendingPathComponent(model.filename)
        return FileManager.default.fileExists(atPath: modelPath.path)
    }
}

// MARK: - Types de données

/// Type de modèle
enum ModelType {
    case speech      // Reconnaissance vocale
    case translation // Traduction
}

/// Erreurs possibles lors de la gestion des modèles
enum ModelError: Error, Identifiable {
    case downloadFailed(String)
    case invalidModel(String)
    case deletionFailed(String)
    
    var id: String {
        switch self {
        case .downloadFailed(let reason): return "download-\(reason)"
        case .invalidModel(let reason): return "invalid-\(reason)"
        case .deletionFailed(let reason): return "deletion-\(reason)"
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .downloadFailed(let reason):
            return "Le téléchargement du modèle a échoué : \(reason)"
        case .invalidModel(let reason):
            return "Modèle invalide : \(reason)"
        case .deletionFailed(let reason):
            return "La suppression du modèle a échoué : \(reason)"
        }
    }
}

/// Informations sur un modèle
struct ModelInfo: Identifiable {
    let id: UUID
    let name: String
    let type: ModelType
    let languages: [Language]
    let sizeInMB: Int
    let downloadURL: URL
    let version: String
    
    var filename: String {
        return "\(name)-\(version).bin"
    }
    
    var localPath: URL? {
        let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let modelsDirectory = appSupportDirectory.appendingPathComponent("MacLocalTranslator/models", isDirectory: true)
        let modelPath = modelsDirectory.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: modelPath.path) {
            return modelPath
        }
        
        return nil
    }
}