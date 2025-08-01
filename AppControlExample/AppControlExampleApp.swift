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
        SBSwitchboardSDK.initialize(withAppID: "YOUR_APP_ID", appSecret: "YOUR_APP_SECRET")
        SBWhisperExtension.initialize(withConfig: [:])
        SBSileroVADExtension.initialize(withConfig: [:])
    }
    var body: some Scene {
        WindowGroup {
            AppControlView()
        }
    }
}
