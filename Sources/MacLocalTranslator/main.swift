//
//  main.swift
//  MacLocalTranslator
//
//  Point d'entrée principal de l'application
//

import SwiftUI

@main
struct MacLocalTranslatorApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var modelManager = ModelManager()
    @StateObject private var preferencesManager = PreferencesManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(modelManager)
                .environmentObject(preferencesManager)
                .onAppear {
                    // Vérifie les modèles nécessaires au démarrage
                    Task {
                        await modelManager.checkRequiredModels()
                    }
                }
        }
        .commands {
            // Menus de l'application
            AppCommands(appState: appState)
        }
        
        // Fenêtre des préférences
        Settings {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(modelManager)
                .environmentObject(preferencesManager)
        }
    }
}
