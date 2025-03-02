//
//  AppCommands.swift
//  MacLocalTranslator
//
//  Définit les commandes de menu de l'application
//

import SwiftUI

struct AppCommands: Commands {
    // MARK: - Propriétés
    
    /// État global de l'application
    var appState: AppState
    
    // MARK: - Corps des commandes
    
    var body: some Commands {
        // Commandes pour le menu Fichier
        CommandGroup(replacing: .newItem) {
            Button("Nouvelle conversation") {
                newConversation()
            }
            .keyboardShortcut("n", modifiers: [.command])
            
            Button("Exporter la conversation...") {
                exportConversation()
            }
            .keyboardShortcut("e", modifiers: [.command])
            .disabled(appState.conversationMessages.isEmpty)
        }
        
        // Commandes pour le menu Édition
        CommandGroup(replacing: .pasteboard) {
            Button("Copier la transcription") {
                copyTranscription()
            }
            .keyboardShortcut("c", modifiers: [.command])
            .disabled(appState.conversationMessages.isEmpty)
            
            Button("Copier la traduction") {
                copyTranslation()
            }
            .keyboardShortcut("c", modifiers: [.command, .option])
            .disabled(appState.conversationMessages.isEmpty)
            
            Divider()
            
            Button("Effacer la conversation") {
                clearConversation()
            }
            .keyboardShortcut("k", modifiers: [.command])
            .disabled(appState.conversationMessages.isEmpty)
        }
        
        // Commandes pour le menu Traduction
        CommandMenu("Traduction") {
            Button("Démarrer l'enregistrement") {
                startRecording()
            }
            .keyboardShortcut(.space, modifiers: [.command])
            .disabled(appState.currentState == .recording)
            
            Button("Arrêter l'enregistrement") {
                stopRecording()
            }
            .keyboardShortcut(.space, modifiers: [.command, .shift])
            .disabled(appState.currentState != .recording)
            
            Divider()
            
            Button("Inverser les langues") {
                switchLanguages()
            }
            .keyboardShortcut("s", modifiers: [.command])
        }
        
        // Commandes pour le menu Affichage
        CommandMenu("Affichage") {
            Button("Augmenter la taille du texte") {
                increaseFontSize()
            }
            .keyboardShortcut("+", modifiers: [.command])
            
            Button("Diminuer la taille du texte") {
                decreaseFontSize()
            }
            .keyboardShortcut("-", modifiers: [.command])
        }
    }
    
    // MARK: - Actions des commandes
    
    /// Crée une nouvelle conversation
    private func newConversation() {
        appState.clearConversation()
    }
    
    /// Exporte la conversation actuelle
    private func exportConversation() {
        // Dans une implémentation réelle, on ouvrirait ici une boîte de dialogue pour exporter la conversation
        print("Exporter la conversation")
    }
    
    /// Copie la transcription de la conversation dans le presse-papiers
    private func copyTranscription() {
        let transcription = appState.conversationMessages
            .map { "\($0.fromSource ? "\u2192" : "\u2190") \($0.original)" }
            .joined(separator: "\n\n")
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(transcription, forType: .string)
    }
    
    /// Copie la traduction de la conversation dans le presse-papiers
    private func copyTranslation() {
        let translation = appState.conversationMessages
            .map { "\($0.fromSource ? "\u2192" : "\u2190") \($0.translated)" }
            .joined(separator: "\n\n")
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(translation, forType: .string)
    }
    
    /// Efface la conversation actuelle
    private func clearConversation() {
        appState.clearConversation()
    }
    
    /// Démarre l'enregistrement
    private func startRecording() {
        appState.startTranslationSession()
    }
    
    /// Arrête l'enregistrement
    private func stopRecording() {
        appState.stopTranslationSession()
    }
    
    /// Inverse les langues source et cible
    private func switchLanguages() {
        appState.switchLanguages()
    }
    
    /// Augmente la taille de la police
    private func increaseFontSize() {
        // Cette fonction nécessiterait l'accès au PreferencesManager
        // Dans une implémentation réelle, on passerait le PreferencesManager en paramètre
        print("Augmenter la taille de la police")
    }
    
    /// Diminue la taille de la police
    private func decreaseFontSize() {
        // Cette fonction nécessiterait l'accès au PreferencesManager
        // Dans une implémentation réelle, on passerait le PreferencesManager en paramètre
        print("Diminuer la taille de la police")
    }
}