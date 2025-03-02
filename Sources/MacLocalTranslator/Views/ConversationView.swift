//
//  ConversationView.swift
//  MacLocalTranslator
//
//  Vue affichant la conversation traduite en temps réel
//

import SwiftUI

struct ConversationView: View {
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var preferencesManager: PreferencesManager
    
    // MARK: - Propriétés calculées
    
    /// Taille de la police configurée dans les préférences
    private var fontSize: CGFloat {
        CGFloat(preferencesManager.fontSize)
    }
    
    // MARK: - Corps de la vue
    
    var body: some View {
        VStack {
            // Titre de la conversation
            HStack {
                Text("Conversation")
                    .font(.headline)
                
                Spacer()
                
                Button(action: clearConversation) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                }
                .buttonStyle(.borderless)
                .help("Effacer la conversation")
            }
            .padding([.horizontal, .top])
            
            // Liste des messages
            if appState.conversationMessages.isEmpty {
                // Message vide
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "text.bubble")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Démarrez une conversation pour commencer la traduction en temps réel")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
            } else {
                // Messages de la conversation
                ScrollView {
                    ScrollViewReader { scrollView in
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(appState.conversationMessages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                        .onChange(of: appState.conversationMessages.count) { _ in
                            // Faire défiler vers le dernier message lorsqu'un nouveau message est ajouté
                            if let lastMessage = appState.conversationMessages.last {
                                withAnimation {
                                    scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }
    
    // MARK: - Actions
    
    /// Efface tous les messages de la conversation
    private func clearConversation() {
        withAnimation {
            appState.clearConversation()
        }
    }
}

// MARK: - Sous-vues

/// Bulle de message individuelle dans la conversation
struct MessageBubbleView: View {
    // MARK: - Propriétés
    
    let message: ConversationMessage
    
    // MARK: - Propriétés de l'environnement
    
    @EnvironmentObject private var appState: AppState
    
    // MARK: - Propriétés calculées
    
    /// Couleur de fond de la bulle
    private var bubbleColor: Color {
        message.fromSource ? Color.blue.opacity(0.1) : Color.green.opacity(0.1)
    }
    
    /// Alignement du message
    private var alignment: HorizontalAlignment {
        message.fromSource ? .leading : .trailing
    }
    
    /// Icone représentant la direction de la traduction
    private var languageIcon: some View {
        HStack(spacing: 4) {
            let sourceLanguage = message.fromSource ? appState.sourceLanguage : appState.targetLanguage
            let targetLanguage = message.fromSource ? appState.targetLanguage : appState.sourceLanguage
            
            Text(sourceLanguage.rawValue.uppercased())
                .font(.system(size: 10, weight: .bold))
            
            Image(systemName: "arrow.right")
                .font(.system(size: 8))
            
            Text(targetLanguage.rawValue.uppercased())
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.secondary)
        .padding(.vertical, 2)
    }
    
    // MARK: - Corps de la vue
    
    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            // Icône de langue et horodatage
            HStack {
                if message.fromSource {
                    languageIcon
                    Spacer()
                    timeText
                } else {
                    timeText
                    Spacer()
                    languageIcon
                }
            }
            
            // Contenu du message
            VStack(alignment: .leading, spacing: 8) {
                // Texte original
                Text(message.original)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                
                // Ligne de séparation
                Divider()
                
                // Texte traduit
                Text(message.translated)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(12)
            .background(bubbleColor)
            .cornerRadius(12)
            .frame(maxWidth: 400, alignment: message.fromSource ? .leading : .trailing)
        }
        .frame(maxWidth: .infinity, alignment: message.fromSource ? .leading : .trailing)
    }
    
    /// Affichage de l'heure du message
    private var timeText: some View {
        Text(timeFormatter.string(from: message.timestamp))
            .font(.system(size: 10))
            .foregroundColor(.secondary)
    }
    
    /// Formatteur pour afficher l'heure
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Prévisualisation SwiftUI

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        
        // Ajouter quelques messages exemples
        let messages = [
            ConversationMessage(
                id: UUID(),
                original: "Bonjour, comment puis-je vous aider aujourd'hui ?",
                translated: "Hello, how can I help you today?",
                timestamp: Date().addingTimeInterval(-120),
                fromSource: true
            ),
            ConversationMessage(
                id: UUID(),
                original: "I'm looking for a restaurant nearby.",
                translated: "Je cherche un restaurant à proximité.",
                timestamp: Date().addingTimeInterval(-60),
                fromSource: false
            )
        ]
        
        appState.conversationMessages = messages
        
        return Group {
            ConversationView()
                .environmentObject(appState)
                .environmentObject(PreferencesManager())
                .frame(width: 500, height: 400)
            
            ConversationView()
                .environmentObject(AppState()) // Sans messages
                .environmentObject(PreferencesManager())
                .frame(width: 500, height: 400)
                .preferredColorScheme(.dark)
        }
    }
}