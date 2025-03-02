//
//  AppStateTests.swift
//  MacLocalTranslatorTests
//
//  Tests unitaires pour AppState
//

import XCTest
@testable import MacLocalTranslator

final class AppStateTests: XCTestCase {
    var appState: AppState!
    
    override func setUp() {
        super.setUp()
        appState = AppState()
    }
    
    override func tearDown() {
        appState = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Vérifier l'état initial
        XCTAssertEqual(appState.currentState, .idle)
        XCTAssertEqual(appState.sourceLanguage, .french)
        XCTAssertEqual(appState.targetLanguage, .english)
        XCTAssertTrue(appState.conversationMessages.isEmpty)
        XCTAssertFalse(appState.isTranslating)
        XCTAssertEqual(appState.currentAudioLevel, 0.0)
    }
    
    func testStartStopTranslationSession() {
        // Démarrer une session
        appState.startTranslationSession()
        XCTAssertEqual(appState.currentState, .recording)
        
        // Arrêter la session
        appState.stopTranslationSession()
        XCTAssertEqual(appState.currentState, .idle)
    }
    
    func testSwitchLanguages() {
        // Définir les langues initiales
        appState.sourceLanguage = .french
        appState.targetLanguage = .english
        
        // Inverser les langues
        appState.switchLanguages()
        
        // Vérifier que les langues ont été inversées
        XCTAssertEqual(appState.sourceLanguage, .english)
        XCTAssertEqual(appState.targetLanguage, .french)
    }
    
    func testAddMessage() {
        // Vérifier qu'il n'y a pas de messages au départ
        XCTAssertEqual(appState.conversationMessages.count, 0)
        
        // Ajouter un message
        appState.addMessage(
            original: "Bonjour",
            translated: "Hello",
            fromSource: true
        )
        
        // Vérifier que le message a été ajouté
        XCTAssertEqual(appState.conversationMessages.count, 1)
        XCTAssertEqual(appState.conversationMessages[0].original, "Bonjour")
        XCTAssertEqual(appState.conversationMessages[0].translated, "Hello")
        XCTAssertTrue(appState.conversationMessages[0].fromSource)
        
        // Ajouter un deuxième message
        appState.addMessage(
            original: "How are you?",
            translated: "Comment allez-vous ?",
            fromSource: false
        )
        
        // Vérifier que le deuxième message a été ajouté
        XCTAssertEqual(appState.conversationMessages.count, 2)
        XCTAssertEqual(appState.conversationMessages[1].original, "How are you?")
        XCTAssertEqual(appState.conversationMessages[1].translated, "Comment allez-vous ?")
        XCTAssertFalse(appState.conversationMessages[1].fromSource)
    }
    
    func testClearConversation() {
        // Ajouter quelques messages
        appState.addMessage(original: "Message 1", translated: "Translation 1", fromSource: true)
        appState.addMessage(original: "Message 2", translated: "Translation 2", fromSource: false)
        
        // Vérifier qu'il y a des messages
        XCTAssertEqual(appState.conversationMessages.count, 2)
        
        // Effacer la conversation
        appState.clearConversation()
        
        // Vérifier que tous les messages ont été supprimés
        XCTAssertEqual(appState.conversationMessages.count, 0)
    }
}