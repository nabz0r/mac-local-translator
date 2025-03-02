//
//  MemoryManager.swift
//  MacLocalTranslator
//
//  Gestionnaire de mémoire pour surveiller et optimiser l'utilisation des ressources
//

import Foundation

class MemoryManager {
    // MARK: - Singleton
    
    /// Instance partagée
    static let shared = MemoryManager()
    
    // MARK: - Types
    
    /// Configuration du gestionnaire de mémoire
    struct Configuration {
        /// Seuil d'utilisation de mémoire considéré comme critique (en pourcentage)
        var criticalMemoryThreshold: Double = 90.0
        
        /// Seuil d'utilisation de mémoire considéré comme un avertissement (en pourcentage)
        var warningMemoryThreshold: Double = 75.0
        
        /// Intervalle de vérification de la mémoire en secondes
        var monitoringInterval: TimeInterval = 5.0
        
        /// Activer ou désactiver la surveillance automatique
        var automaticMonitoring: Bool = true
    }
    
    /// État actuel de la mémoire
    enum MemoryState {
        case normal
        case warning
        case critical
    }
    
    // MARK: - Propriétés
    
    /// Configuration actuelle
    var configuration = Configuration()
    
    /// État actuel de la mémoire
    private(set) var currentState: MemoryState = .normal
    
    /// Pourcentage actuel d'utilisation de la mémoire
    private(set) var currentMemoryUsage: Double = 0.0
    
    /// Timer pour la surveillance automatique
    private var monitoringTimer: Timer?
    
    // MARK: - Initialisation
    
    private init() {
        // Initialisation privée pour empêcher la création d'instances multiples
    }
    
    // MARK: - Surveillance de la mémoire
    
    /// Démarre la surveillance automatique de la mémoire
    func startMonitoring() {
        guard configuration.automaticMonitoring, monitoringTimer == nil else { return }
        
        monitoringTimer = Timer.scheduledTimer(
            timeInterval: configuration.monitoringInterval,
            target: self,
            selector: #selector(checkMemoryUsage),
            userInfo: nil,
            repeats: true
        )
        
        // Exécuter immédiatement une première vérification
        checkMemoryUsage()
        
        Logger.info("Surveillance de la mémoire démarrée avec un intervalle de \(configuration.monitoringInterval) secondes", category: .system)
    }
    
    /// Arrête la surveillance automatique de la mémoire
    func stopMonitoring() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        Logger.info("Surveillance de la mémoire arrêtée", category: .system)
    }
    
    /// Vérifie manuellement l'utilisation de la mémoire
    @objc func checkMemoryUsage() {
        // Obtenir l'utilisation actuelle de la mémoire
        currentMemoryUsage = getMemoryUsage()
        
        // Déterminer l'état de la mémoire
        let previousState = currentState
        
        if currentMemoryUsage >= configuration.criticalMemoryThreshold {
            currentState = .critical
        } else if currentMemoryUsage >= configuration.warningMemoryThreshold {
            currentState = .warning
        } else {
            currentState = .normal
        }
        
        // Journaliser si l'état a changé
        if previousState != currentState {
            logMemoryStateChange(from: previousState, to: currentState)
        }
        
        // Réagir en fonction de l'état
        switch currentState {
        case .critical:
            performCriticalMemoryActions()
        case .warning:
            performWarningMemoryActions()
        case .normal:
            break // Aucune action nécessaire
        }
    }
    
    // MARK: - Actions de gestion de la mémoire
    
    /// Exécute des actions lorsque l'utilisation de la mémoire est critique
    private func performCriticalMemoryActions() {
        // Forcer la libération des ressources non essentielles
        freeMemory(aggressive: true)
        
        // Notifier l'application
        NotificationCenter.default.post(
            name: .criticalMemoryWarning,
            object: nil,
            userInfo: ["memoryUsage": currentMemoryUsage]
        )
    }
    
    /// Exécute des actions lorsque l'utilisation de la mémoire atteint le seuil d'avertissement
    private func performWarningMemoryActions() {
        // Libérer des ressources non essentielles
        freeMemory(aggressive: false)
        
        // Notifier l'application
        NotificationCenter.default.post(
            name: .memoryWarning,
            object: nil,
            userInfo: ["memoryUsage": currentMemoryUsage]
        )
    }
    
    /// Libère de la mémoire en fonction de la sévérité
    func freeMemory(aggressive: Bool) {
        // Nettoyage des caches et des ressources temporaires
        autoreleasepool {
            // Vider les caches en mémoire
            URLCache.shared.removeAllCachedResponses()
            
            // Libérer explicitement quelques ressources si nécessaire
            // (Ceci est principalement symbolique, car Swift/ARC gère automatiquement la mémoire)
        }
        
        // En mode agressif, des mesures supplémentaires peuvent être prises
        if aggressive {
            // Notifier l'utilisateur si nécessaire
            Logger.warning("Mémoire critique : \(String(format: "%.1f", currentMemoryUsage))% utilisée", category: .system)
        }
    }
    
    // MARK: - Utilitaires
    
    /// Obtient le pourcentage d'utilisation de la mémoire
    private func getMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            // Convertir les informations obtenues en pourcentage
            let usedMemory = Double(info.resident_size) / 1024.0 / 1024.0 // Mo
            let physicalMemory = Double(ProcessInfo.processInfo.physicalMemory) / 1024.0 / 1024.0 // Mo
            
            let percentUsed = (usedMemory / physicalMemory) * 100.0
            return min(percentUsed, 100.0) // Limiter à 100%
        }
        
        return 0.0
    }
    
    /// Journalise les changements d'état de la mémoire
    private func logMemoryStateChange(from oldState: MemoryState, to newState: MemoryState) {
        let message = "Changement d'état de la mémoire : \(describeState(oldState)) -> \(describeState(newState)) (\(String(format: "%.1f", currentMemoryUsage))%)"
        
        switch newState {
        case .normal:
            Logger.info(message, category: .system)
        case .warning:
            Logger.warning(message, category: .system)
        case .critical:
            Logger.logError(message, category: .system)
        }
    }
    
    /// Convertit un état en description textuelle
    private func describeState(_ state: MemoryState) -> String {
        switch state {
        case .normal: return "Normal"
        case .warning: return "Avertissement"
        case .critical: return "Critique"
        }
    }
}

// MARK: - Extensions

extension Notification.Name {
    /// Notification envoyée lorsque l'utilisation de la mémoire atteint le seuil d'avertissement
    static let memoryWarning = Notification.Name("MemoryManagerWarning")
    
    /// Notification envoyée lorsque l'utilisation de la mémoire atteint le seuil critique
    static let criticalMemoryWarning = Notification.Name("MemoryManagerCritical")
}
