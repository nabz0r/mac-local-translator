//
//  FileManager+Extensions.swift
//  MacLocalTranslator
//
//  Extensions du FileManager pour faciliter les opérations sur les fichiers
//

import Foundation

extension FileManager {
    /// Répertoire d'application support de l'application
    static var applicationSupportDirectory: URL? {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.
            appendingPathComponent("MacLocalTranslator")
    }
    
    /// Répertoire des modèles
    static var modelsDirectory: URL? {
        guard let appSupportDir = applicationSupportDirectory else { return nil }
        return appSupportDir.appendingPathComponent("models")
    }
    
    /// Répertoire des journaux
    static var logsDirectory: URL? {
        guard let appSupportDir = applicationSupportDirectory else { return nil }
        return appSupportDir.appendingPathComponent("logs")
    }
    
    /// Répertoire de l'historique des conversations
    static var historyDirectory: URL? {
        guard let appSupportDir = applicationSupportDirectory else { return nil }
        return appSupportDir.appendingPathComponent("history")
    }
    
    /// Crée un répertoire s'il n'existe pas
    static func createDirectoryIfNeeded(at url: URL) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            
            Logger.info("Répertoire créé : \(url.path)", category: .storage)
        }
    }
    
    /// Crée tous les répertoires nécessaires pour l'application
    static func createApplicationDirectories() {
        do {
            if let appSupportDir = applicationSupportDirectory {
                try createDirectoryIfNeeded(at: appSupportDir)
            }
            
            if let modelsDir = modelsDirectory {
                try createDirectoryIfNeeded(at: modelsDir)
            }
            
            if let logsDir = logsDirectory {
                try createDirectoryIfNeeded(at: logsDir)
            }
            
            if let historyDir = historyDirectory {
                try createDirectoryIfNeeded(at: historyDir)
            }
        } catch {
            Logger.error("Erreur lors de la création des répertoires : \(error.localizedDescription)", category: .storage)
        }
    }
    
    /// Nettoie les fichiers journaux anciens
    static func cleanupOldLogFiles(olderThan days: Int = 30) {
        guard let logsDir = logsDirectory else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: logsDir,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            
            for fileURL in fileURLs {
                if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                   let creationDate = attributes[.creationDate] as? Date,
                   creationDate < cutoffDate {
                    try FileManager.default.removeItem(at: fileURL)
                    Logger.info("Fichier journal ancien supprimé : \(fileURL.lastPathComponent)", category: .storage)
                }
            }
        } catch {
            Logger.error("Erreur lors du nettoyage des fichiers journaux : \(error.localizedDescription)", category: .storage)
        }
    }
    
    /// Calcule la taille d'un répertoire
    static func directorySize(at url: URL) -> Int64 {
        let fileManager = FileManager.default
        var size: Int64 = 0
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.fileSizeKey],
                options: .skipsHiddenFiles
            )
            
            for fileURL in contents {
                let isDirectory = (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
                
                if isDirectory {
                    size += directorySize(at: fileURL)
                } else {
                    let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                    size += (attributes[.size] as? Int64) ?? 0
                }
            }
            
            return size
        } catch {
            Logger.error("Erreur lors du calcul de la taille du répertoire : \(error.localizedDescription)", category: .storage)
            return 0
        }
    }
    
    /// Formate une taille en octets en une chaîne lisible
    static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}