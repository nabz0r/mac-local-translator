//
//  TranslationServiceTests.swift
//  MacLocalTranslatorTests
//
//  Tests unitaires pour TranslationService
//

import XCTest
@testable import MacLocalTranslator

final class TranslationServiceTests: XCTestCase {
    var translationService: TranslationService!
    var modelManager: ModelManager!
    
    override func setUp() {
        super.setUp()
        
        // Créer un ModelManager avec des modèles de test
        modelManager = ModelManager()
        
        // Modèle de traduction fictif pour les tests
        let translationModel = ModelInfo(
            id: UUID(),
            name: "test-translate-model",
            type: .translation,
            languages: [.french, .english],
            sizeInMB: 100,
            downloadURL: URL(string: "https://example.com/test-model")!,
            version: "1.0"
        )
        
        modelManager.availableTranslationModels = [translationModel]
        modelManager.selectedTranslationModel = translationModel
        
        // Initialiser le service de traduction
        translationService = TranslationService(modelManager: modelManager)
    }
    
    override func tearDown() {
        translationService = nil
        modelManager = nil
        super.tearDown()
    }
    
    func testTranslateEmptyText() async {
        // Traduire un texte vide
        let result = await translationService.translate(
            text: "",
            from: .french,
            to: .english
        )
        
        // Vérifier que le résultat est une erreur
        switch result {
        case .success:
            XCTFail("La traduction d'un texte vide devrait échouer")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
    
    func testTranslateSameLanguage() async {
        // Texte de test
        let testText = "Bonjour le monde"
        
        // Traduire entre les mêmes langues
        let result = await translationService.translate(
            text: testText,
            from: .french,
            to: .french
        )
        
        // Vérifier que le texte est retourné inchangé
        switch result {
        case .success(let translation):
            XCTAssertEqual(translation.sourceText, testText)
            XCTAssertEqual(translation.translatedText, testText)
            XCTAssertEqual(translation.sourceLanguage, .french)
            XCTAssertEqual(translation.targetLanguage, .french)
            XCTAssertEqual(translation.confidence, 1.0)
        case .failure:
            XCTFail("La traduction entre les mêmes langues ne devrait pas échouer")
        }
    }
    
    func testTranslateWithoutModel() async {
        // Configurer un modèle inexistant
        modelManager.selectedTranslationModel = nil
        
        // Tenter une traduction
        let result = await translationService.translate(
            text: "Hello world",
            from: .english,
            to: .french
        )
        
        // Vérifier que le résultat est une erreur
        switch result {
        case .success:
            XCTFail("La traduction sans modèle devrait échouer")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
    
    func testTranslateSuccessful() async {
        // Texte de test
        let testText = "Hello world"
        
        // Traduire avec des langues différentes
        let result = await translationService.translate(
            text: testText,
            from: .english,
            to: .french
        )
        
        // Vérifier le résultat
        switch result {
        case .success(let translation):
            XCTAssertEqual(translation.sourceText, testText)
            XCTAssertNotEqual(translation.translatedText, testText)
            XCTAssertEqual(translation.sourceLanguage, .english)
            XCTAssertEqual(translation.targetLanguage, .french)
            XCTAssertGreaterThan(translation.confidence, 0.0)
        case .failure(let error):
            XCTFail("La traduction a échoué avec l'erreur : \(error.localizedDescription)")
        }
    }
    
    func testStateTransitions() async {
        // Vérifier l'état initial
        XCTAssertEqual(translationService.state, .idle)
        
        // Traduire un texte
        _ = await translationService.translate(
            text: "Hello",
            from: .english,
            to: .french
        )
        
        // Vérifier l'état après traduction
        // Note: Comme la traduction est asynchrone, l'état attendu dépend de la rapidité d'exécution
        // Dans un cas réel, on utiliserait des attentes pour vérifier les transitions d'état
        XCTAssertNotEqual(translationService.state, .translating)
    }
}