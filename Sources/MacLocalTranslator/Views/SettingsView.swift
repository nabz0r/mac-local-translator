//
//  SettingsView.swift
//  MacLocalTranslator
//
//  Vue des paramètres de l'application
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var preferencesManager: PreferencesManager
    @EnvironmentObject private var modelManager: ModelManager
    
    // MARK: - Corps de la vue
    
    var body: some View {
        TabView {
            // Onglet Général
            generalTab
                .tabItem {
                    Label("Général", systemImage: "gear")
                }
            
            // Onglet Audio
            audioTab
                .tabItem {
                    Label("Audio", systemImage: "waveform")
                }
            
            // Onglet Modèles
            modelsTab
                .tabItem {
                    Label("Modèles", systemImage: "square.stack.3d.up")
                }
            
            // Onglet Langues
            languagesTab
                .tabItem {
                    Label("Langues", systemImage: "text.bubble")
                }
        }
        .padding(20)
        .frame(width: 550, height: 400)
    }
    
    // MARK: - Onglets
    
    /// Onglet des paramètres généraux
    private var generalTab: some View {
        Form {
            // Apparence
            Section(header: Text("Apparence")) {
                Toggle("Utiliser le mode sombre", isOn: $preferencesManager.useDarkMode)
                
                Stepper(value: $preferencesManager.fontSize, in: 10...24) {
                    Text("Taille de police: \(preferencesManager.fontSize)pt")
                }
            }
            
            // Historique
            Section(header: Text("Historique")) {
                Toggle("Enregistrer l'historique des conversations", isOn: $preferencesManager.saveHistory)
                
                if preferencesManager.saveHistory {
                    Stepper(value: $preferencesManager.historyRetentionDays, in: 1...365) {
                        Text("Conserver l'historique pendant: \(preferencesManager.historyRetentionDays) jours")
                    }
                }
                
                Button("Effacer tout l'historique") {
                    // Implémentation future: effacer l'historique
                }
                .disabled(!preferencesManager.saveHistory)
            }
            
            // Réinitialisation
            Section {
                Button("Réinitialiser tous les paramètres") {
                    preferencesManager.resetToDefaults()
                }
                .foregroundColor(.red)
            }
        }
    }
    
    /// Onglet des paramètres audio
    private var audioTab: some View {
        Form {
            // Entrée audio
            Section(header: Text("Entrée audio")) {
                // Dans une implémentation réelle, on listerait ici les périphériques d'entrée
                Text("Microphone par défaut du système")
                    .foregroundColor(.secondary)
                
                Slider(value: $preferencesManager.silenceThreshold, in: 0.05...0.5) {
                    Text("Seuil de détection de silence: \(preferencesManager.silenceThreshold, specifier: "%.2f")")
                }
                
                Slider(value: $preferencesManager.silenceDuration, in: 0.5...5.0, step: 0.1) {
                    Text("Durée de silence pour fin de parole: \(preferencesManager.silenceDuration, specifier: "%.1f") s")
                }
            }
            
            // Sortie audio
            Section(header: Text("Sortie audio")) {
                // Dans une implémentation réelle, on listerait ici les périphériques de sortie
                Text("Haut-parleurs par défaut du système")
                    .foregroundColor(.secondary)
                
                Slider(value: $preferencesManager.outputVolume, in: 0...1) {
                    Text("Volume de sortie: \(Int(preferencesManager.outputVolume * 100))%")
                }
            }
            
            // Mode d'enregistrement
            Section(header: Text("Mode d'enregistrement")) {
                Toggle("Mode manuel", isOn: $preferencesManager.useManualMode)
                
                Text(preferencesManager.useManualMode ? 
                     "Vous devrez appuyer manuellement pour commencer et arrêter l'enregistrement." :
                     "L'enregistrement s'arrêtera automatiquement après une période de silence.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    /// Onglet des modèles de traduction et reconnaissance vocale
    private var modelsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Modèles de reconnaissance vocale
            Section(header: Text("Modèles de reconnaissance vocale").font(.headline)) {
                if modelManager.availableSpeechModels.isEmpty {
                    Text("Aucun modèle de reconnaissance vocale disponible")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    // Liste des modèles disponibles
                    ForEach(modelManager.availableSpeechModels) { model in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.name)
                                    .font(.headline)
                                Text("Taille: \(model.sizeInMB) MB | Version: \(model.version)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Indicateur de sélection
                            if modelManager.selectedSpeechModel?.id == model.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            modelManager.selectedSpeechModel = model
                        }
                    }
                }
                
                Button("Télécharger d'autres modèles...") {
                    // Implémentation future
                }
                .padding(.top, 8)
            }
            
            Divider()
            
            // Modèles de traduction
            Section(header: Text("Modèles de traduction").font(.headline)) {
                if modelManager.availableTranslationModels.isEmpty {
                    Text("Aucun modèle de traduction disponible")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    // Liste des modèles disponibles
                    ForEach(modelManager.availableTranslationModels) { model in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.name)
                                    .font(.headline)
                                Text("Taille: \(model.sizeInMB) MB | Version: \(model.version)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Indicateur de sélection
                            if modelManager.selectedTranslationModel?.id == model.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            modelManager.selectedTranslationModel = model
                        }
                    }
                }
                
                Button("Télécharger d'autres modèles...") {
                    // Implémentation future
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
    }
    
    /// Onglet des langues
    private var languagesTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Langues disponibles")
                .font(.headline)
            
            // Liste des langues
            List(Language.allCases) { language in
                HStack {
                    Text(language.displayName)
                        .font(.body)
                    
                    Spacer()
                    
                    // Statut d'installation
                    Text("Installé")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text("Pour ajouter une nouvelle langue, vous devez télécharger les modèles correspondants dans l'onglet 'Modèles'.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Prévisualisation SwiftUI

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(PreferencesManager())
            .environmentObject(ModelManager())
    }
}