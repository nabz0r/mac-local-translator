//
//  WhisperStub.swift
//  MacLocalTranslator
//
//  Stub implementation to replace Whisper.cpp dependency
//

import Foundation

/// A stub implementation to replace the Whisper.cpp dependency
public struct WhisperModel {
    /// Simulates loading a model from a file
    public static func load(from path: String) -> WhisperModel? {
        Logger.info("Stub: Loading Whisper model from \(path)", category: .speech)
        return WhisperModel()
    }
    
    /// Simulates transcribing audio data
    public func transcribe(_ audioData: Data) -> String {
        // In a real implementation, this would use the Whisper.cpp library
        // For the stub, we return sample transcriptions
        
        let sampleTranscriptions = [
            "Bonjour, comment puis-je vous aider aujourd'hui ?",
            "Je voudrais réserver un billet pour Paris.",
            "Pourriez-vous m'indiquer le chemin vers la gare ?",
            "J'aimerais commander un café, s'il vous plaît.",
            "Quel temps fait-il aujourd'hui ?"
        ]
        
        // Return a random sample transcription
        return sampleTranscriptions.randomElement() ?? "Bonjour"
    }
}
