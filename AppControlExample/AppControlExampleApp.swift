//
//  AppControlExampleApp.swift
//  AppControlExample
//
//  Created by Tayyab Javed on 2025-07-02.
//

import SwiftUI
import SwitchboardSDK
import SwitchboardSileroVAD
import SwitchboardWhisper


@main
struct AppControlExampleApp: App {

    init () {
        SBWhisperExtension.loadExtension()
        SBSileroVADExtension.loadExtension()
        let initConfig: [String: Any] = [
            "appID": "YOUR_APP_ID",
            "appSecret": "YOUR_APP_SECRET",
            "extensions": [
                "Whisper": [:],
                "Silero": [:],
            ],
        ]
        Switchboard.initialize(withConfig: initConfig)
    }
    var body: some Scene {
        WindowGroup {
            AppControlView()
        }
    }
}
