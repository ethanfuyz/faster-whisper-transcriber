//
//  SRTTranscriberApp.swift
//  SRTTranscriber
//
//  Created by Ethan Fu on 19/6/2025.
//

import SwiftUI

@main
struct SRTTranscriberApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        window.title = "SRT Transcriber"
                    }
                }
        }
    }
}
