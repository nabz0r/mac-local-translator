//
//  ToolbarView.swift
//  MacLocalTranslator
//
//  Barre d'outils supérieure contenant les contrôles principaux
//

import SwiftUI

struct ToolbarView: View {
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var appState: AppState
    
    // MARK: - Corps de la vue
    
    var body: some View {
        HStack {
            // Sélecteurs de langues
            LanguageSelectorView(isSource: true)
                .frame(width: 150)
            
            // Bouton d'inversion des langues
            Button(action: switchLanguages) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 16, weight: .medium))
            }
            .buttonStyle(.borderless)
            .keyboardShortcut("s", modifiers: [.command])
            .help("Inverser les langues")
            
            LanguageSelectorView(isSource: false)
                .frame(width: 150)
            
            Spacer()
            
            // Bouton d'enregistrement
            RecordingButton()
                .frame(width: 100)
            
            Spacer()
            
            // Indicateur de niveau audio
            AudioLevelIndicator(level: appState.currentAudioLevel)
                .frame(width: 100, height: 20)
            
            // Bouton de paramètres
            Button(action: openSettings) {
                Image(systemName: "gear")
                    .font(.system(size: 16))
            }
            .buttonStyle(.borderless)
            .keyboardShortcut(",", modifiers: [.command])
            .help("Paramètres")
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    /// Inverse les langues source et cible
    private func switchLanguages() {
        appState.switchLanguages()
    }
    
    /// Ouvre la fenêtre des paramètres
    private func openSettings() {
        NSApp.sendAction(Selector("showPreferencesWindow:"), to: nil, from: nil)
    }
}

// MARK: - Sous-vues

/// Indicateur visuel du niveau audio
struct AudioLevelIndicator: View {
    let level: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Fond de l'indicateur
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                
                // Barre de niveau
                RoundedRectangle(cornerRadius: 3)
                    .fill(levelColor)
                    .frame(width: CGFloat(level) * geometry.size.width)
            }
        }
    }
    
    // Couleur basée sur le niveau audio
    private var levelColor: Color {
        if level < 0.3 {
            return .green
        } else if level < 0.7 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Prévisualisation SwiftUI

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView()
            .environmentObject(AppState())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}