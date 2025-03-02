//
//  Logger.swift
//  MacLocalTranslator
//
//  Service de journalisation pour faciliter le débogage
//

import Foundation
import os.log

class Logger {
    // MARK: - Catégories de journalisation
    
    /// Niveau de journalisation
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
        
        /// Emoji associé au niveau pour faciliter la lecture
        var emoji: String {
            switch self {
            case .debug: return "\u{1F41E}" // bug
            case .info: return "\u{2139}\u{FE0F}" // info
            case .warning: return "\u{26A0}\u{FE0F}" // warning
            case .error: return "\u{274C}" // cross mark
            case .critical: return "\u{1F6A8}" // rotating light
            }
        }
    }
    
    /// Catégorie du message
    enum Category: String {
        case audio = "Audio"
        case speech = "SpeechRecognition"
        case translation = "Translation"
        case models = "Models"
        case ui = "UI"
        case storage = "Storage"
        case system = "System"
    }
    
    // MARK: - Propriétés statiques
    
    /// Niveau de journalisation actuel
    static var logLevel: Level = .info
    
    /// Active ou désactive la journalisation dans un fichier
    static var logToFile: Bool = true
    
    /// Chemin du fichier de journalisation
    static var logFilePath: URL? = {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let logsDirectory = appSupportURL.appendingPathComponent("MacLocalTranslator/logs")
        
        do {
            try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
            
            return logsDirectory.appendingPathComponent("translator_\(dateString).log")
        } catch {
            print("Erreur lors de la création du répertoire de journalisation: \(error)")
            return nil
        }
    }()
    
    // MARK: - Méthodes de journalisation
    
    /// Journalise un message au niveau DEBUG
    static func debug(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    /// Journalise un message au niveau INFO
    static func info(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    /// Journalise un message au niveau WARNING
    static func warning(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    /// Journalise un message au niveau ERROR
    static func logError(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    /// Journalise un message au niveau CRITICAL
    static func critical(_ message: String, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Méthode de journalisation principale
    
    /// Méthode principale de journalisation
    private static func log(_ message: String, level: Level, category: Category, file: String, function: String, line: Int) {
        // Vérifier si le niveau de journalisation actuel permet d'afficher ce message
        guard shouldLog(level) else { return }
        
        // Formatter le message
        let formattedMessage = formatLogMessage(message, level: level, category: category, file: file, function: function, line: line)
        
        // Journaliser dans la console
        logToConsole(formattedMessage, level: level, category: category)
        
        // Journaliser dans un fichier si activé
        if logToFile, let logFilePath = logFilePath {
            logToFileAtPath(formattedMessage, path: logFilePath)
        }
    }
    
    // MARK: - Méthodes auxiliaires
    
    /// Détermine si un message doit être journalisé en fonction de son niveau
    private static func shouldLog(_ level: Level) -> Bool {
        switch (logLevel, level) {
        case (.debug, _):
            return true
        case (.info, .info), (.info, .warning), (.info, .error), (.info, .critical):
            return true
        case (.warning, .warning), (.warning, .error), (.warning, .critical):
            return true
        case (.error, .error), (.error, .critical):
            return true
        case (.critical, .critical):
            return true
        default:
            return false
        }
    }
    
    /// Formate un message de journalisation
    private static func formatLogMessage(_ message: String, level: Level, category: Category, file: String, function: String, line: Int) -> String {
        let timestamp = formatTimestamp(Date())
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        
        return "\(timestamp) | \(level.emoji) \(level.rawValue) | [\(category.rawValue)] | \(fileName):\(line) | \(function) | \(message)"
    }
    
    /// Formate un horodatage
    private static func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
    
    /// Journalise un message dans la console
    private static func logToConsole(_ message: String, level: Level, category: Category) {
        let osLogType: OSLogType
        
        switch level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .warning:
            osLogType = .default
        case .error:
            osLogType = .error
        case .critical:
            osLogType = .fault
        }
        
        let osLog = OSLog(subsystem: "com.maclocaltranslator", category: category.rawValue)
        os_log("%{public}@", log: osLog, type: osLogType, message)
    }
    
    /// Écrit un message dans un fichier de journalisation
    private static func logToFileAtPath(_ message: String, path: URL) {
        let messageWithNewline = message + "\n"
        
        guard let data = messageWithNewline.data(using: .utf8) else { return }
        
        do {
            // Créer le fichier s'il n'existe pas, sinon ajouter à la fin
            if FileManager.default.fileExists(atPath: path.path) {
                let fileHandle = try FileHandle(forWritingTo: path)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try data.write(to: path, options: .atomic)
            }
        } catch {
            // Fallback si l'écriture dans le fichier échoue
            print("Erreur lors de l'écriture dans le fichier de journalisation: \(error)")
        }
    }
}

// MARK: - Extensions pratiques

extension Logger {
    /// Journalise une fonction au début et à la fin de son exécution avec le temps écoulé
    static func logFunction(category: Category, file: String = #file, function: String = #function, line: Int = #line, block: () throws -> Void) rethrows {
        let startTime = Date()
        debug("Début de la fonction", category: category, file: file, function: function, line: line)
        
        do {
            try block()
        } catch {
            logError("Exception: \(error.localizedDescription)", category: category, file: file, function: function, line: line)
            throw error
        }
        
        let timeElapsed = Date().timeIntervalSince(startTime)
        debug("Fin de la fonction (durée: \(String(format: "%.3f", timeElapsed))s)", category: category, file: file, function: function, line: line)
    }
    
    /// Journalise une fonction asynchrone au début et à la fin de son exécution avec le temps écoulé
    static func logAsyncFunction(category: Category, file: String = #file, function: String = #function, line: Int = #line, block: () async throws -> Void) async rethrows {
        let startTime = Date()
        debug("Début de la fonction asynchrone", category: category, file: file, function: function, line: line)
        
        do {
            try await block()
        } catch {
            logError("Exception: \(error.localizedDescription)", category: category, file: file, function: function, line: line)
            throw error
        }
        
        let timeElapsed = Date().timeIntervalSince(startTime)
        debug("Fin de la fonction asynchrone (durée: \(String(format: "%.3f", timeElapsed))s)", category: category, file: file, function: function, line: line)
    }
}