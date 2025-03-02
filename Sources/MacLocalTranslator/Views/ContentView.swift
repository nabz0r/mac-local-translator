//
//  ContentView.swift
//  MacLocalTranslator
//
//  Vue principale de l'application qui contient l'interface utilisateur globale
//

import SwiftUI

struct ContentView: View {
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var modelManager: ModelManager
    @EnvironmentObject private var preferencesManager: PreferencesManager
    
    // MARK: - États locaux
    
    @State private var showSetupGuide = false
    
    // MARK: - Corps de la vue
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barre d'outils supérieure
                ToolbarView()
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                
                // Vue principale divisée en deux parties
                HStack(spacing: 0) {
                    // Panneau de conversation
                    ConversationView()
                        .frame(minWidth: 300)
                    
                    // Séparateur
                    Divider()
                    
                    // Panneau de contrôle
                    ControlPanelView()
                        .frame(width: 250)
                }
            }
            .onAppear {
                // Vérifier si c'est le premier lancement
                if modelManager.availableSpeechModels.isEmpty {
                    showSetupGuide = true
                }
            }
            .sheet(isPresented: $showSetupGuide) {
                SetupGuideView(isPresented: $showSetupGuide)
            }
        }
        .navigationTitle("Mac Local Translator")
        .frame(minWidth: 800, minHeight: 600)
    }
}

// MARK: - Prévisualisation SwiftUI

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(ModelManager())
            .environmentObject(PreferencesManager())
    }
}