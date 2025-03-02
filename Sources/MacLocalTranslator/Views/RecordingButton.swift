//
//  RecordingButton.swift
//  MacLocalTranslator
//
//  Bouton d'enregistrement avec animation pour démarrer/arrêter l'enregistrement
//

import SwiftUI

struct RecordingButton: View {
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var preferencesManager: PreferencesManager
    
    // MARK: - États
    
    @State private var isAnimating = false
    
    // MARK: - Propriétés calculées
    
    /// Indique si l'enregistrement est en cours
    private var isRecording: Bool {
        appState.currentState == .recording
    }
    
    /// Texte du bouton
    private var buttonText: String {
        isRecording ? "Arrêter" : "Démarrer"
    }
    
    /// Couleur du bouton
    private var buttonColor: Color {
        isRecording ? .red : .green
    }
    
    /// Icône du bouton
    private var buttonIcon: String {
        isRecording ? "stop.fill" : "mic.fill"
    }
    
    // MARK: - Corps de la vue
    
    var body: some View {
        Button(action: toggleRecording) {
            HStack {
                Image(systemName: buttonIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(isRecording && isAnimating ? 0.5 : 1.0) // Clignotement si enregistrement en cours
                
                Text(buttonText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(height: 30)
            .frame(maxWidth: .infinity)
            .background(buttonColor)
            .cornerRadius(15)
        }
        .buttonStyle(.borderless)
        .keyboardShortcut(.space, modifiers: [.command])
        .help(isRecording ? "Arrêter l'enregistrement" : "Démarrer l'enregistrement")
        .onAppear {
            if isRecording {
                startBlinkingAnimation()
            }
        }
        .onChange(of: isRecording) { newValue in
            if newValue {
                startBlinkingAnimation()
            }
        }
    }
    
    // MARK: - Actions
    
    /// Alterne l'état d'enregistrement
    private func toggleRecording() {
        // En mode manuel, contrôle direct de l'enregistrement
        if preferencesManager.useManualMode {
            if isRecording {
                appState.stopTranslationSession()
            } else {
                appState.startTranslationSession()
            }
        } else {
            // En mode automatique, démarre une session complète de traduction
            if isRecording {
                appState.stopTranslationSession()
            } else {
                appState.startTranslationSession()
            }
        }
    }
    
    /// Démarre l'animation de clignotement pendant l'enregistrement
    private func startBlinkingAnimation() {
        guard isRecording else { return }
        
        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) {
            isAnimating = true
        }
    }
}

// MARK: - Prévisualisation SwiftUI

struct RecordingButton_Previews: PreviewProvider {
    static var previews: some View {
        let recordingState = AppState()
        recordingState.currentState = .recording
        
        let idleState = AppState()
        
        return Group {
            RecordingButton()
                .environmentObject(idleState)
                .environmentObject(PreferencesManager())
                .padding()
                .frame(width: 150)
                .previewDisplayName("État normal")
            
            RecordingButton()
                .environmentObject(recordingState)
                .environmentObject(PreferencesManager())
                .padding()
                .frame(width: 150)
                .previewDisplayName("Enregistrement en cours")
        }
        .previewLayout(.sizeThatFits)
    }
}