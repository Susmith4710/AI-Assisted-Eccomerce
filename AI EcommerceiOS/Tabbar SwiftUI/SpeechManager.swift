//
//  SpeechManager.swift
//  Tabbar SwiftUI
//
//  Created by Erikneon on 12/31/24.
//

import Foundation
import AVFAudio

class SpeechManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []
    
    override init() {
        super.init()
        loadAvailableVoices()
    }
    
    private func loadAvailableVoices() {
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
    }
    
    func speak(text: String, rate: Float, voiceIdentifier: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        
        if let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            utterance.voice = voice
        }
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
