//
//  ControlPanelView.swift
//  MacLocalTranslator
//
//  Panneau de contrôle avec des informations sur l'état actuel et les paramètres
//

import SwiftUI
import AppKit

struct ControlPanelView: View {
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var modelManager: ModelManager
    @EnvironmentObject private var preferencesManager: PreferencesManager
    
    // MARK: - États
    
    @State private var volume: Float = 0.8
    
    // MARK: - Corps de la vue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Titre
            Text("Panneau de contrôle")
                .font(.headline)
                .padding(.top)
            
            // Section d'état
            statusSection
            
            // Section de contrôle du volume
            volumeSection
            
            // Section des modèles actifs
            modelsSection
            
            Spacer()
            
            // Section du mode manuel
            manualModeSection
            
            // Section des statistiques
            statsSection
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            self.volume = preferencesManager.outputVolume
        }
    }
    
    // MARK: - Sections
    
    /// Section affichant l'état actuel de l'application
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("État")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                
                Text(statusText)
                    .font(.system(size: 14))
            }
            .padding(.vertical, 4)
        }
    }
    
    /// Section pour régler le volume de sortie
    private var volumeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Volume de sortie")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "speaker.wave.1")
                    .foregroundColor(.secondary)
                
                Slider(value: $volume, in: 0...1) { changed in
                    if changed {
                        preferencesManager.outputVolume = volume
                    }
                }
                
                Image(systemName: "speaker.wave.3")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    /// Section affichant les modèles actifs
    private var modelsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Modèles actifs")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Modèle de reconnaissance vocale
            if let speechModel = modelManager.selectedSpeechModel {
                HStack {
                    Image(systemName: "waveform.circle")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(speechModel.name)
                            .font(.system(size: 13))
                        Text("Reconnaissance vocale")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
            
            // Modèle de traduction
            if let translationModel = modelManager.selectedTranslationModel {
                HStack {
                    Image(systemName: "text.bubble")
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(translationModel.name)
                            .font(.system(size: 13))
                        Text("Traduction")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
            
            // Bouton pour gérer les modèles
            Button("Gérer les modèles...") {
                openModelManager()
            }
            .font(.system(size: 13))
            .padding(.top, 4)
        }
    }
    
    /// Section pour activer/désactiver le mode manuel
    private var manualModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Mode manuel", isOn: $preferencesManager.useManualMode)
                .font(.system(size: 14))
            
            if preferencesManager.useManualMode {
                Text("Appuyez sur le bouton pour commencer et arrêter l'enregistrement. La traduction démarrera lorsque vous arrêterez l'enregistrement.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("La traduction démarrera automatiquement après une pause de \(String(format: "%.1f", preferencesManager.silenceDuration)) secondes.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    /// Section affichant les statistiques
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Statistiques")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            let messageCount = appState.conversationMessages.count
            
            Text("\(messageCount) message\(messageCount > 1 ? "s" : "") dans cette session")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Propriétés calculées
    
    /// Couleur représentant l'état actuel
    private var statusColor: Color {
        switch appState.currentState {
        case .idle:
            return .gray
        case .recording:
            return .red
        case .processing:
            return .orange
        case .error:
            return .red
        }
    }
    
    /// Texte décrivant l'état actuel
    private var statusText: String {
        switch appState.currentState {
        case .idle:
            return "En attente"
        case .recording:
            return "Enregistrement en cours"
        case .processing:
            return "Traitement en cours"
        case .error:
            return "Erreur"
        }
    }
    
    // MARK: - Actions
    
    /// Ouvre le gestionnaire de modèles dans les préférences
    private func openModelManager() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        // Dans une implémentation réelle, on pourrait également sélectionner l'onglet des modèles
    }
}

// MARK: - Prévisualisation SwiftUI

struct ControlPanelView_Previews: PreviewProvider {
    static var previews: some View {
        let recordingState = AppState()
        recordingState.currentState = .recording
        
        let idleState = AppState()
        
        return Group {
            ControlPanelView()
                .environmentObject(idleState)
                .environmentObject(ModelManager())
                .environmentObject(PreferencesManager())
                .frame(width: 250, height: 600)
                .previewDisplayName("État normal")
            
            ControlPanelView()
                .environmentObject(recordingState)
                .environmentObject(ModelManager())
                .environmentObject(PreferencesManager())
                .frame(width: 250, height: 600)
                .previewDisplayName("Enregistrement en cours")
                .preferredColorScheme(.dark)
        }
    }
}