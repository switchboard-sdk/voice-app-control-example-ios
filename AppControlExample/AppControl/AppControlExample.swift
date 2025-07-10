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

            let result = TriggerDetector.detectTrigger(transcriptionText)
            
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
        TriggerDetector.setRuntimeTriggers(triggers)
    }
    
    deinit {
        if let listenerID = transcriptionListenerID {
            Switchboard.removeEventListener("sttNode", listenerID: listenerID)
        }
    }
}
