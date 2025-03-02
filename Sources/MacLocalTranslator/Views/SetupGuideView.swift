//
//  SetupGuideView.swift
//  MacLocalTranslator
//
//  Assistant de configuration au premier lancement
//

import SwiftUI

struct SetupGuideView: View {
    // MARK: - Propriétés
    
    @Binding var isPresented: Bool
    
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var modelManager: ModelManager
    
    // MARK: - États
    
    @State private var currentStep = 0
    @State private var selectedLanguages: [Language] = [.french, .english]
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0.0
    
    // MARK: - Corps de la vue
    
    var body: some View {
        VStack {
            // Titre
            Text("Bienvenue dans Mac Local Translator")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            // Étapes
            TabView(selection: $currentStep) {
                // Étape 1: Introduction
                welcomeStep
                    .tag(0)
                
                // Étape 2: Sélection des langues
                languageSelectionStep
                    .tag(1)
                
                // Étape 3: Téléchargement des modèles
                downloadStep
                    .tag(2)
                
                // Étape 4: Configuration terminée
                completionStep
                    .tag(3)
            }
            // Utiliser un style de TabView compatible macOS
            .tabViewStyle(.automatic)
            .frame(width: 500, height: 400)
            
            // Indicateur d'étape
            HStack(spacing: 8) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(currentStep == index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            
            // Boutons de navigation
            HStack {
                // Bouton Précédent
                Button("Précédent") {
                    if currentStep > 0 {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                }
                .disabled(currentStep == 0 || isDownloading)
                
                Spacer()
                
                // Bouton Suivant/Terminer
                Button(currentStep == 3 ? "Terminer" : "Suivant") {
                    if currentStep < 3 {
                        withAnimation {
                            currentStep += 1
                        }
                        
                        // Si on passe à l'étape de téléchargement, démarrer le téléchargement
                        if currentStep == 2 {
                            startDownload()
                        }
                    } else {
                        // Terminé
                        isPresented = false
                    }
                }
                .disabled(isDownloading && currentStep == 2)
            }
            .padding()
        }
        .frame(width: 550, height: 500)
    }
    
    // MARK: - Étapes
    
    /// Étape 1: Écran de bienvenue
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding()
            
            Text("Mac Local Translator")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Cette application vous permet de traduire des conversations en temps réel sans connexion internet, garantissant ainsi votre confidentialité.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Nous allons vous guider à travers quelques étapes pour configurer l'application.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    /// Étape 2: Sélection des langues
    private var languageSelectionStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sélectionnez vos langues")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Choisissez au moins deux langues que vous souhaitez utiliser pour la traduction. Vous pourrez ajouter d'autres langues plus tard.")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Liste des langues
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Language.allCases) { language in
                        Toggle(language.displayName, isOn: Binding(
                            get: { selectedLanguages.contains(language) },
                            set: { isSelected in
                                if isSelected {
                                    selectedLanguages.append(language)
                                } else {
                                    // Garder au moins 2 langues sélectionnées
                                    if selectedLanguages.count > 2 {
                                        selectedLanguages.removeAll { $0 == language }
                                    }
                                }
                            }
                        ))
                        .disabled(selectedLanguages.count <= 2 && selectedLanguages.contains(language))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Text("Langues sélectionnées: \(selectedLanguages.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
    }
    
    /// Étape 3: Téléchargement des modèles
    private var downloadStep: some View {
        VStack(spacing: 20) {
            Text("Téléchargement des modèles")
                .font(.title3)
                .fontWeight(.bold)
            
            if isDownloading {
                // Progression du téléchargement
                VStack(spacing: 10) {
                    ProgressView(value: downloadProgress, total: 1.0)
                        .frame(height: 8)
                    
                    Text("\(Int(downloadProgress * 100))%")
                        .font(.caption)
                }
                .padding()
                
                Text("Téléchargement des modèles nécessaires pour les langues sélectionnées. Cela peut prendre quelques minutes selon votre connexion internet.")
                    .multilineTextAlignment(.center)
            } else {
                // Téléchargement terminé
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding()
                
                Text("Téléchargement terminé !")
                    .font(.headline)
                
                Text("Tous les modèles nécessaires ont été téléchargés avec succès.")
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
    
    /// Étape 4: Configuration terminée
    private var completionStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .padding()
            
            Text("Félicitations !")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Mac Local Translator est maintenant prêt à être utilisé. Vous pouvez commencer à traduire vos conversations en temps réel.")
                .multilineTextAlignment(.center)
            
            Text("Pour démarrer une conversation, il vous suffit de cliquer sur le bouton 'Démarrer' dans l'interface principale.")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Méthodes
    
    /// Démarre le téléchargement des modèles
    private func startDownload() {
        isDownloading = true
        downloadProgress = 0.0
        
        // Dans une implémentation réelle, on lancerait ici les téléchargements des modèles
        // Pour cette version prototype, on simule le téléchargement
        
        // Simulation d'un téléchargement progressif
        let downloadDuration = 3.0 // 3 secondes pour la simulation
        let stepCount = 20
        let stepDuration = downloadDuration / Double(stepCount)
        
        for i in 1...stepCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                withAnimation {
                    downloadProgress = Double(i) / Double(stepCount)
                    
                    // Quand le téléchargement est terminé
                    if i == stepCount {
                        isDownloading = false
                        
                        // Mettre à jour les langues sélectionnées dans l'application
                        if !selectedLanguages.isEmpty {
                            appState.sourceLanguage = selectedLanguages[0]
                            if selectedLanguages.count > 1 {
                                appState.targetLanguage = selectedLanguages[1]
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Prévisualisation SwiftUI

struct SetupGuideView_Previews: PreviewProvider {
    static var previews: some View {
        SetupGuideView(isPresented: .constant(true))
            .environmentObject(AppState())
            .environmentObject(ModelManager())
    }
}