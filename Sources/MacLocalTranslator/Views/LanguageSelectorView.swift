//
//  LanguageSelectorView.swift
//  MacLocalTranslator
//
//  Vue pour sélectionner la langue source ou cible
//

import SwiftUI

struct LanguageSelectorView: View {
    // MARK: - Propriétés
    
    /// Indique si ce sélecteur est pour la langue source (true) ou cible (false)
    let isSource: Bool
    
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var appState: AppState
    
    // MARK: - Propriétés calculées
    
    /// Liaison avec la langue sélectionnée (source ou cible)
    private var selectedLanguage: Binding<Language> {
        if isSource {
            return $appState.sourceLanguage
        } else {
            return $appState.targetLanguage
        }
    }
    
    /// Titre du sélecteur
    private var title: String {
        isSource ? "De" : "Vers"
    }
    
    // MARK: - Corps de la vue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Étiquette
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Menu déroulant
            Picker("", selection: selectedLanguage) {
                ForEach(Language.allCases) { language in
                    Text(language.displayName)
                        .tag(language)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
}

// MARK: - Prévisualisation SwiftUI

struct LanguageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            LanguageSelectorView(isSource: true)
            LanguageSelectorView(isSource: false)
        }
        .environmentObject(AppState())
        .padding()
        .previewLayout(.sizeThatFits)
    }
}