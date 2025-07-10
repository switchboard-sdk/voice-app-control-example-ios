import SwiftUI
import Foundation
import SwitchboardSDK

class AppControlEngine {
    weak var delegate: AppControlDelegate?
    private var transcriptionListenerID: NSNumber?
    private var engineID: String!
    
    func createEngine() {
        guard let filePath = Bundle.main.path(forResource: "AudioGraph", ofType: "json"),
              let jsonString = try? String(contentsOfFile: filePath, encoding: .utf8)
        else {
            print("Error reading JSON file")
            return
        }

        guard let jsonData = jsonString.data(using: .utf8),
              let config = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            print("Error parsing JSON")
            return
        }

        let createEngineResult = Switchboard.createEngine(withConfig: config)
        guard createEngineResult.success else {
            fatalError("Failed to create audio engine: \(createEngineResult.error?.localizedDescription ?? "Unknown error")")
        }

        engineID = createEngineResult.value! as String
        
        let listenerResult = Switchboard.addEventListener("sttNode", eventName: "transcription") { [weak self] eventData in
            guard let self = self,
                  let transcriptionText = eventData as? String else { return }

            let result = StringUtils.detectTrigger(transcriptionText)
            
            if result.detected {
                DispatchQueue.main.async {
                    self.delegate?.triggerDetected(result.triggerType.rawValue, withKeyword: result.keyword)
                }
            }
        }

        if let listenerID = listenerResult.value {
            transcriptionListenerID = listenerID
        } else {
            print("Failed to add event listener: \(listenerResult.error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func startEngine() {
        let startEngineResult = Switchboard.callAction(withObjectID: engineID, actionName: "start", params: nil)
        if startEngineResult.error != nil {
            print("Failed to start audio engine: \(startEngineResult.error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func stopEngine() {
        let stopEngineResult = Switchboard.callAction(withObjectID: engineID, actionName: "stop", params: nil)
        if stopEngineResult.error != nil {
            print("Failed to stop audio engine: \(stopEngineResult.error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func setRuntimeTriggers(_ triggers: [String]) {
        StringUtils.setRuntimeTriggers(triggers)
    }
    
    deinit {
        if let listenerID = transcriptionListenerID {
            Switchboard.removeEventListener("sttNode", listenerID: listenerID)
        }
    }
}

class AppControlDelegate: NSObject, ObservableObject {
    @Published var detectedKeyword = ""
    
    weak var verticalListViewModel: ListViewModel?
    
    // Trigger mode handler with detected keyword
    func triggerDetected(_ triggerType: Int, withKeyword keyword: String) {
        guard let mode = TriggerType(rawValue: triggerType) else { return }
        
        DispatchQueue.main.async {
            self.detectedKeyword = keyword
            
            switch mode {
            case .next:
                self.verticalListViewModel?.goNext()
            case .back:
                self.verticalListViewModel?.goBack()
            case .like:
                self.verticalListViewModel?.toggleLike()
            case .dislike:
                self.verticalListViewModel?.toggleDislike()
            case .expand:
                self.verticalListViewModel?.toggleExpand()
            case .runtimeTriggers:
                // Find the movie by title and select it
                if let movieIndex = self.verticalListViewModel?.items.firstIndex(where: { $0.title.lowercased() == keyword }) {
                    self.verticalListViewModel?.selectItem(at: movieIndex)
                }
            case .unknown:
                print("unknown command")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.detectedKeyword = ""
        }
    }
}

struct AppControlView: View {
    @StateObject private var delegate = AppControlDelegate()
    @StateObject private var verticalListViewModel = ListViewModel()
    @State private var engine: AppControlEngine?

    var body: some View {
        VStack(spacing: 10) {
            Text("Voice Control Demo")
                .font(.title)
                .padding()
            
            Text("- You can navigate by saying title of a movie \n- Execute actions with following commands \n- Up | Down | Like | Dislike | Expand")
            
            Text(delegate.detectedKeyword)
                .fontWeight(.semibold)
                .font(.callout)
                .frame(minHeight: 20)

            Spacer()
            
            ListView(viewModel: verticalListViewModel)
            
        }
        .padding()
        .onAppear {
            engine = AppControlEngine()
            engine?.delegate = delegate
            delegate.verticalListViewModel = verticalListViewModel
            
            // Set runtime triggers with movie titles from data
            let movieTitles = DataSource.shared.movieData.map { $0.title }
            engine?.setRuntimeTriggers(movieTitles)
            
            engine?.createEngine()
            engine?.startEngine()
        }
        .onDisappear {
            engine?.stopEngine()
        }
    }
}
