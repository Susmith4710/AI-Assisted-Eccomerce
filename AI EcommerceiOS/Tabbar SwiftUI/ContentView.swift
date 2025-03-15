////
////  ContentView.swift
////  Tabbar SwiftUI
////
////  Created by Erikneon on 8/2/24.
////

import SwiftUI
import AVFoundation


struct ContentView: View, NetworkManagerDelegate {
    
    //STEP 4: Detailing about the protocols to be executed
    func didUpdateData(_networkManager: NetworkManager, data: ItemList) {
        DispatchQueue.main.async {
            self.data = data
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
    
    
    //initializing it using @static re renders or makes it mutable perfectky suited for chaniging data such as api
    @State private var data: ItemList = []
    @State private var errorMessage: String = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedIndex: Int = 0
    
    @State private var networkManager = NetworkManager() // Add this line
    
    
    //STEP 3: Using the networkmanager delegate created in the network manager class to use it here
    //    var networkManager: NetworkManagerDelegate?
    var body: some View {
        NavigationView {
            customUI(data: data)
        }
        .onAppear {
            var networkManager = NetworkManager()
            networkManager.delegate = self
            networkManager.fetchData()
            
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.red
            UITabBar.appearance().standardAppearance = appearance
            
        }
    }
    
    
    struct customUI: View {
        @State private var selectedIndex: Int = 0
        
        //we are just using the data from the @static private var data: ItemList = [] which can be used by its child classes also
        let data:ItemList
        var body: some View {
            NavigationView {
                TabView(selection:$selectedIndex) {
                    NavigationStack() {
                        ScrollView {
                            VStack(alignment: .leading){
                                HStack {
                                    cardView()
                                    cardView()
                                }
                                
                                HStack {
                                    cardView()
                                    cardView()
                                    
                                }
                                
                                HStack {
                                    cardView()
                                    cardView()
                                }
                                HStack {
                                    cardView()
                                    cardView()
                                }
                            }
                        }
                        .background(Color.black)
                    }
                    .tabItem {
                        Text("Home view")
                        Image(systemName: "house.fill")
                            .resizable()
                        
                    }.tag(0)
                    
                    //Profile View
                    NavigationStack() {
                        table(data:data)
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }.tag(1)
                }
                .navigationTitle("Dishes")
            }
            .background(Color.brown)
        }
    }
    
    struct table: View {
        let data: ItemList // Immutable input data
        @State private var selectedItems: Set<Int> = []
        @State private var cartAdded: [Int: Bool] = [:]
        @State private var searchText: String = "" // Search text state
        @State private var isRecording = false
        @State private var statusText = "Ready to Record"
        @State private var timerText = "Duration: 0.0 seconds"
        @State private var transcriptionText = ""
        @State private var recordingDuration: TimeInterval = 0
        @State private var audioRecorder: AVAudioRecorder?
        @State private var timer: Timer?
        @State private var searchDebounceTimer: Timer?
        
        @State private var text: String = ""
        @State private var speechRate: Float = 0.5
        @State private var selectedVoice: String = "com.apple.ttsbundle.siri_male_en-US_compact"
        @StateObject private var speechManager = SpeechManager()
        @StateObject private var manager = VoiceAssistantManager()
        
        
        private let openAIAPIKey = "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" // Replace with your actual key
        
        
        var filteredData: ItemList {
            if transcriptionText.isEmpty {
                return data
            } 
            else {
                return data.filter { item in
                    item.dish_name?.localizedCaseInsensitiveContains(transcriptionText) ?? false
                }
            }
  }
        
        var body: some View {
            NavigationStack {    
                
                
                
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
                
                
                
                Button(action: toggleRecording) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRecording ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                
                
//                Section {
//                    Button(action: {
//                        speechManager.speak(text: transcriptionText, rate: speechRate, voiceIdentifier: selectedVoice)
//                    }) {
//                        HStack {
//                            Image(systemName: "play.circle.fill")
//                            Text("Speak")
//                        }
//                    }
//                    
//                    Button(action: {
//                        speechManager.stopSpeaking()
//                    }) {
//                        HStack {
//                            Image(systemName: "stop.circle.fill")
//                            Text("Stop")
//                        }
//                    }
//                }
                .onAppear {
                    configureAudioSession()
                    //  logAvailableVoices() // Log available voices for debugging
                }
                List(filteredData, id: \.id) { item in
                    VStack(alignment: .leading) {
                        NavigationLink(destination: secondView(item: item)) {
                            VStack {
                                AsyncImage(url: URL(string: item.image_url ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .shadow(radius: 10)
                                        .cornerRadius(20)
                                        .padding(10)
                                } placeholder: {
                                    ProgressView() // Placeholder while loading image
                                }
                                
                                Text(item.dish_name ?? "")
                                    .font(.headline)
                                
                                Text("\(item.ratings ?? 2.3, specifier: "%.1f")")
                                    .font(.footnote)
                            }
                        }
                    }
                }
                .searchable(text: $transcriptionText, prompt: "Search dishes") // Add searchable modifier
                //                .onSubmit {
                //                    // Trigger text-to-speech when user submits the search
                //                    if !searchText.isEmpty {
                //                        speechManager.speak(text: transcriptionText, rate: speechRate, voiceIdentifier: selectedVoice)
                //                    }
                //                }
                
                .onChange(of: manager.assistantResponse) { response in
                    if response.contains("Checking availability") {
                        manager.sendToPredictionService(message: "Check availability of Tandoori Chicken.")
                    } else if response.contains("Placing your order") {
                        NetworkManager().placeOrder(dishName: "Tandoori Chicken", quantity: 2) { success in
                            if success {
                                print("Order placed successfully!")
                            } else {
                                print("Failed to place order.")
                            }
                        }
                    } else if response.contains("Canceling the order") {
                        NetworkManager().cancelOrder(dishName: "Tandoori Chicken") { success in
                            if success {
                                print("Order canceled successfully!")
                            } else {
                                print("Failed to cancel order.")
                            }
                        }
                    }
                }
                .navigationTitle("Menu")
                
            }
            .onAppear {
                configureAudioSession()
                
            }
            
        }
        
        private func toggleRecording() {
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }
        
        private func stopRecording() {
            audioRecorder?.stop()
            timer?.invalidate()
            timer = nil
            
            // Reset UI
            isRecording = false
            statusText = "Recording Stopped"
            
            // Transcribe audio
            if let audioFileURL = audioRecorder?.url {
                transcribeAudio(audioFileURL: audioFileURL)
            }
        }
        
        
        private func startRecording() {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(Date().timeIntervalSince1970).m4a")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder?.record()
                
                // Update UI
                isRecording = true
                statusText = "Recording..."
                transcriptionText = ""
                
                // Start timer
                recordingDuration = 0
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    recordingDuration += 0.1
                    timerText = String(format: "Duration: %.1f seconds", recordingDuration)
                    
                    // Auto stop after 30 seconds
                    if recordingDuration >= 30 {
                        stopRecording()
                    }
                }
            } catch {
                statusText = "Recording Failed: \(error.localizedDescription)"
            }
        }
        
        private func transcribeAudio(audioFileURL: URL) {
            transcriptionText = "Transcribing..."
            
            guard let url = URL(string: "https://api.openai.com/v1/audio/transcriptions") else {
                transcriptionText = "Invalid API URL"
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            do {
                let audioData = try Data(contentsOf: audioFileURL)
                
                // Add file part
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
                body.append(audioData)
                body.append("\r\n".data(using: .utf8)!)
                
                // Add model parameter
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
                body.append("whisper-1\r\n".data(using: .utf8)!)
                
                // Close boundary
                body.append("--\(boundary)--\r\n".data(using: .utf8)!)
                
                request.httpBody = body
            } catch {
                transcriptionText = "Error reading audio file: \(error.localizedDescription)"
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        transcriptionText = "Error: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let data = data else {
                        transcriptionText = "No data received"
                        return
                    }
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let transcription = json["text"] as? String {
                            transcriptionText = transcription
                        } else {
                            transcriptionText = "Transcription text not found in response"
                        }
                    } catch {
                        transcriptionText = "Parsing error: \(error.localizedDescription)"
                    }
                }
            }.resume()
        }
        
        private func configureAudioSession() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                statusText = "Audio session setup failed: \(error.localizedDescription)"
            }
        }
        
    }
    
}
  
struct cardView:View {
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: secondView(item:nil)) {
                Image("Interstellar").resizable().frame(width:170, height:190)
                    .aspectRatio(contentMode: .fit)
                    .border(Color.red, width: 2)
                    .border(Color.black)
                .shadow(radius: 10)
            }
            Text("Interstellar").font(.title2)
                .foregroundStyle(Color.white)
            HStack() {
                Image(systemName: "timer")
                    .foregroundStyle(Color.white)
                Text("119 min")
                    .foregroundStyle(Color.white)
            }
        }.cornerRadius(10)
    }
}
  

struct Order: Identifiable,Codable {
    let id = UUID()
    let dishname:String
    
}

struct secondView:View {
    let item: ModelData?
    @State private var searchText = ""

    @State private var orders: [Order] = []
        var body: some View {
            
            ScrollView {
                VStack {
                    if let item = item {
                        Text("\(item.dish_name ?? "Unknown")")
                            .font(.title)
                            .padding()
                        
                        AsyncImage(url: URL(string: item.image_url ?? "")) {
                            image in image
                                .image?.resizable()
                                .aspectRatio(contentMode: .fit)
                                .shadow(radius: 10)
                                .cornerRadius(20)
                                .padding(.leading,60)
                                .padding(.trailing,60)
                                .padding(.top,20)
                                .padding(.bottom,20)
                        }
                        
                        Text("Noodles are a versatile, long, and thin food made from unleavened dough, often boiled or stir-fried. Popular in Asian cuisines, they come in various forms like ramen, udon, and soba. Noodles are enjoyed with sauces, broths, vegetables, or meats, making them a staple in many global dishes. ")
                            .padding(.all,30)
                        
                        Button(action: {
                            print("Order slected")
                            if let dish_name = item.dish_name {
                                let newOrder = Order(dishname: dish_name)
                                orders.append(newOrder)
                            }
                        }){
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                    .padding(.all,10)
                                Text("Add to cart")
                            }
                        }
                        
                        Button (action: {
                            postOrdersToAPI(orders:orders) }) {
                                Text("Send orders")
                                    .font(.headline)
                        }
                    } else {
                        Text("No item selected")
                    }
                }
                .navigationTitle("Home")
            }
        }
    }
    

func postOrdersToAPI(orders: [Order]) {
    guard let url = URL(string: "http://localhost:3001/api/restaurants/menu") else {
        print("Invalid URL")
        return
    }
    
    // Prepare the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    
    // Encode the orders array into JSON
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(orders)
        request.httpBody = jsonData
    } catch {
        print("Error encoding orders: \(error)")
        return
    }
    
    // Make the POST request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error posting orders: \(error)")
            return
        }
        
        if let response = response as? HTTPURLResponse, response.statusCode == 200 {
            // Successfully posted the orders
            print("Orders posted successfully")
            // After successful post, make a new request for each order to send dishname and id
            for order in orders {

                postDishNameWithID(order: order)

            }
        } else {
            print("Failed to post orders")
        }
    }.resume()
}

// Function to post dishname and new id when posting successfully
func postDishNameWithID(order: Order) {
    guard let url = URL(string: "http://localhost:3001/api/restaurant/menu") else {
        print("Invalid URL for dishname")
        return
    }
    
    // Prepare the new request with dishname and id
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Create a dictionary with dishname and id
    let newOrderData = [
        "id": order.id.uuidString,
        "dishname": order.dishname
    ]
    
    // Encode the new order data into JSON
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(newOrderData)
        request.httpBody = jsonData
    } catch {
        print("Error encoding new order data: \(error)")
        return
    }
    
    // Send the new POST request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error posting new order data: \(error)")
            return
        }
        if let response = response as? HTTPURLResponse, response.statusCode == 200 {
            print("Dishname \(order.dishname) with ID \(order.id) posted successfully")
        } else {
            print("Failed to post dishname \(order.dishname)")
        }
    }.resume()
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


