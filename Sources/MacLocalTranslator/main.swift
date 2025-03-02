//
//  main.swift
//  MacLocalTranslator
//
//  Point d'entrée principal de l'application
//

import SwiftUI
import AppKit

// Point d'entrée principal de l'application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    // Gestionnaires de l'état global de l'application
    var appState: AppState!
    var modelManager: ModelManager!
    var preferencesManager: PreferencesManager!
    
    // Fenêtre principale de l'application
    var window: NSWindow!
    
    // Configuration des préférences
    var settingsWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialiser les gestionnaires d'état
        appState = AppState()
        modelManager = ModelManager()
        preferencesManager = PreferencesManager()
        
        // Créer la fenêtre principale
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Mac Local Translator"
        window.center()
        
        // Configuration du contenu avec SwiftUI
        let contentView = ContentView()
            .environmentObject(appState)
            .environmentObject(modelManager)
            .environmentObject(preferencesManager)
        
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        // Vérifier les modèles nécessaires au démarrage
        Task {
            await modelManager.checkRequiredModels()
        }
    }
    
    // Gère l'ouverture de la fenêtre des préférences
    @objc func showPreferencesWindow(_ sender: Any?) {
        if settingsWindow == nil {
            // Créer la fenêtre des préférences si elle n'existe pas
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 550, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.title = "Préférences"
            settingsWindow?.center()
            
            // Configuration du contenu avec SwiftUI
            let settingsView = SettingsView()
                .environmentObject(appState)
                .environmentObject(modelManager)
                .environmentObject(preferencesManager)
            
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    
    // Gère la fermeture de l'application
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // Gère la fermeture de l'application
    func applicationWillTerminate(_ notification: Notification) {
        // Nettoyage avant la fermeture si nécessaire
    }
}