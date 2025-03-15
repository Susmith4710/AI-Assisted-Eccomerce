//
//  VoiceAssistantManager.swift
//  Tabbar SwiftUI
//
//  Created by Erikneon on 1/2/25.
//

import SwiftUI
import AVFoundation
import Speech

//class VoiceAssistantManager: NSObject, ObservableObject {
//    private let speechSynthesizer = AVSpeechSynthesizer()
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//    
//    @Published var isRecording = false
//    @Published var transcribedText = ""
//    @Published var assistantResponse = ""
//    @Published var isProcessing = false
//    
//    private let openAIKey = "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" // Replace with your API key
//    
//    override init() {
//        super.init()
//        requestPermissions()
//    }
//    
//    private func requestPermissions() {
//        SFSpeechRecognizer.requestAuthorization { status in
//            DispatchQueue.main.async {
//                switch status {
//                case .authorized:
//                    print("Speech recognition authorized")
//                default:
//                    print("Speech recognition authorization denied")
//                }
//            }
//        }
//    }
//    
//    func toggleRecording() {
//        isRecording ? stopRecording() : startRecording()
//    }
//    
//    private func startRecording() {
//        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
//            print("Speech recognition not available")
//            return
//        }
//        
//        do {
//            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//            guard let recognitionRequest = recognitionRequest else { return }
//            
//            let inputNode = audioEngine.inputNode
//            recognitionRequest.shouldReportPartialResults = true
//            
//            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//                guard let self = self else { return }
//                if let result = result {
//                    self.transcribedText = result.bestTranscription.formattedString
//                    print("Transcribed Text: \(self.transcribedText)")
//                }
//            }
//            
//            let recordingFormat = inputNode.outputFormat(forBus: 0)
//            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//                recognitionRequest.append(buffer)
//            }
//            
//            audioEngine.prepare()
//            try audioEngine.start()
//            isRecording = true
//            
//        } catch {
//            print("Recording failed: \(error)")
//        }
//    }
//    
//    private func stopRecording() {
//        audioEngine.stop()
//        recognitionRequest?.endAudio()
//        audioEngine.inputNode.removeTap(onBus: 0)
//        recognitionTask?.cancel()
//        
//        isRecording = false
//        sendToPredictionService(message: transcribedText)
//    }
//    
//    
//    func sendToPredictionService(message: String) {
//        isProcessing = true
//        
//        guard let url = URL(string: "http://127.0.0.1:6001/predict") else {
//            assistantResponse = "Invalid server URL."
//            isProcessing = false
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body: [String: Any] = ["text": message]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                self.isProcessing = false
//                
//                if let error = error {
//                    self.assistantResponse = "Error: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    self.assistantResponse = "No data received from the server."
//                    return
//                }
//                
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let intent = json["intent"] as? String {
//                        self.handleIntent(intent: intent)
//                    } else {
//                        self.assistantResponse = "Invalid response from server."
//                    }
//                } catch {
//                    self.assistantResponse = "Error parsing server response: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//
//    
//    private func handleIntent(intent: String) {
//        switch intent {
//        case "check_availability":
//            print("Placing order logic triggered1.")
//            assistantResponse = "Checking item availability..."
//            NetworkManager().fetchData() // Fetch data from the `/menu` endpoint and update the UI.
//        case "place_order":
//            print("Placing order logic triggered2.")
//            assistantResponse = "Placing your order..."
//            // Use NetworkManager to send order details to `/order` endpoint.
//        case "ask_price":
//            print("Placing order logic triggered3.")
//            assistantResponse = "Fetching price details..."
//            // Example: fetch item prices and display them.
//        case "cancel_order":
//            print("Placing order logic triggered4.")
//            assistantResponse = "Canceling the order..."
//            // Example: cancel order using DELETE request.
//        default:
//            print("Placing order logic triggered5.")
//            assistantResponse = "Sorry, I didn't understand that command."
//        }
//    }
//
//    
//    private func speakResponse(_ text: String) {
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.rate = 0.5
//        utterance.pitchMultiplier = 1.0
//        utterance.volume = 0.8
//        
//        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
//            utterance.voice = voice
//        }
//        
//        speechSynthesizer.speak(utterance)
//    }
//}

// VoiceAssistantManager.swift
import SwiftUI
import AVFoundation
import Speech

class VoiceAssistantManager: NSObject, ObservableObject {
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var assistantResponse = ""
    @Published var isProcessing = false
    private var networkManager = NetworkManager()
    
    override init() {
        super.init()
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized")
                default:
                    print("Speech recognition authorization denied")
                }
            }
        }
    }
    
    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }
    
    private func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognition not available")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            let inputNode = audioEngine.inputNode
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                if let result = result {
                    DispatchQueue.main.async {
                        self.transcribedText = result.bestTranscription.formattedString
                    }
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            DispatchQueue.main.async {
                self.isRecording = true
                self.transcribedText = ""
                self.assistantResponse = "Listening..."
            }
            
        } catch {
            print("Recording failed: \(error)")
            self.assistantResponse = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.processCommand()
        }
    }
    
    private func processCommand() {
        guard !transcribedText.isEmpty else {
            self.assistantResponse = "No command detected"
            return
        }
        
        isProcessing = true
        self.assistantResponse = "Processing command..."
        
        // First, get the intent from the ML model
        networkManager.fetchPrediction(for: transcribedText) { [weak self] intent in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let intent = intent {
                    self.handleIntent(intent: intent)
                } else {
                    self.isProcessing = false
                    self.assistantResponse = "Failed to process command"
                }
            }
        }
    }
    
    private func handleIntent(intent: String) {
        // Extract item name from transcribed text
        let words = transcribedText.lowercased().split(separator: " ")
        guard let itemName = words.last?.description else {
            self.assistantResponse = "Could not identify item name"
            self.isProcessing = false
            return
        }
        
        switch intent {
        case "check_availability":
            networkManager.fetchAvailability(dishName: itemName) { [weak self] available in
                DispatchQueue.main.async {
                    self?.isProcessing = false
                    if available {
                        self?.assistantResponse = "\(itemName) is available"
                    } else {
                        self?.assistantResponse = "\(itemName) is not available"
                    }
                }
            }
            
        case "place_order":
            networkManager.placeOrder(dishName: itemName, quantity: 1) { [weak self] success in
                DispatchQueue.main.async {
                    self?.isProcessing = false
                    if success {
                        self?.assistantResponse = "Order placed for \(itemName)"
                    } else {
                        self?.assistantResponse = "Failed to place order for \(itemName)"
                    }
                }
            }
            
        case "cancel_order":
            networkManager.cancelOrder(dishName: itemName) { [weak self] success in
                DispatchQueue.main.async {
                    self?.isProcessing = false
                    if success {
                        self?.assistantResponse = "Cancelled order for \(itemName)"
                    } else {
                        self?.assistantResponse = "Failed to cancel order for \(itemName)"
                    }
                }
            }
            
        default:
            self.isProcessing = false
            self.assistantResponse = "Unrecognized command"
        }
    }
}

// Update in ContentView.swift - table struct
struct table: View {
    // ... existing properties ...
    @StateObject private var voiceAssistant = VoiceAssistantManager()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Voice command button
                Button(action: {
                    voiceAssistant.toggleRecording()
                }) {
                    HStack {
                        Image(systemName: voiceAssistant.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 44))
                        Text(voiceAssistant.isRecording ? "Stop" : "Start")
                            .font(.title2)
                    }
                    .foregroundColor(voiceAssistant.isRecording ? .red : .blue)
                }
                .padding()
                
                // Status text
                if !voiceAssistant.transcribedText.isEmpty {
                    Text("Heard: \(voiceAssistant.transcribedText)")
                        .padding()
                }
                
                if !voiceAssistant.assistantResponse.isEmpty {
                    Text(voiceAssistant.assistantResponse)
                        .padding()
                }
                
                if voiceAssistant.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
                
                // Existing list view
                List(filteredData, id: \.id) { item in
                    // ... existing list item code ...
                }
            }
            .navigationTitle("Menu")
        }
    }
}
class VoiceAssistantManager: NSObject, ObservableObject
struct VoiceAssistantView: View {
    @StateObject private var manager = VoiceAssistantManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                manager.toggleRecording()
            }) {
                HStack {
                    Image(systemName: manager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 44))
                    Text(manager.isRecording ? "Stop" : "Start")
                        .font(.title2)
                }
                .foregroundColor(manager.isRecording ? .red : .blue)
            }
            .padding()
            
            if manager.isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
                    }
        .padding()
    }
}
