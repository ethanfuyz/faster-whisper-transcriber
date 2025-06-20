//
//  ContentView.swift
//  SRTTranscriber
//
//  Created by Ethan Fu on 19/6/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

struct ContentView: View {
    @State private var selectedFileURL: URL? = nil
    @State private var isDropTargeted = false
    @State private var isGenerating = false
    @State private var progressText = "Generate"
    @State private var totalDuration: Double = 0
    @State private var selectedModel = "medium"
    let availableModels = ["tiny", "base", "small", "medium", "large-v3"]
    @State private var convertTraditionalToSimplified = true

    var body: some View {
        VStack(spacing: 30) {
            Text("SRT Transcriber")
                .font(.largeTitle)
                .bold()

            HStack(spacing: 12) {
                Text(selectedFileURL?.lastPathComponent ?? "Select File")
                    .foregroundColor(.secondary)
                    .padding(15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isDropTargeted ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                    .onDrop(
                        of: [.fileURL],
                        isTargeted: $isDropTargeted,
                        perform: handleDrop(providers:)
                    )

                Button(action: openFilePanel) {
                    Text("Browse")
                        .fontWeight(.semibold)
                        .padding(15)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            HStack {
                Picker("Model", selection: $selectedModel) {
                    ForEach(availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 4)

                Toggle("繁 <> 简", isOn: $convertTraditionalToSimplified)
                    .toggleStyle(SwitchToggleStyle())
                    .padding(.leading, 12)
            }

            Button(action: {
                Task {
                    await runPythonScript()
                }
            }) {
                Text(progressText)
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isGenerating ? Color.gray : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isGenerating)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(minWidth: 300, idealWidth: 380, maxWidth: 420, minHeight: 250, idealHeight: 270, maxHeight: 290)
    }

    func getDurationSeconds(for url: URL) async -> Double? {
        let asset = AVURLAsset(url: url)
        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            print("⚠️ Failed to load duration: \(error)")
            return nil
        }
    }

    private func runPythonScript() async {
        print("Generate button clicked")

        guard let inputURL = selectedFileURL else {
            print("No input file selected.")
            return
        }

        if let duration = await getDurationSeconds(for: inputURL), duration.isFinite {
            totalDuration = duration
        } else {
            totalDuration = 0
        }

        let pythonPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".venv/srt_transcriber_env/bin/python3")
            .path
        guard let scriptPath = Bundle.main.path(forResource: "transcribe_to_srt", ofType: "py") else {
            print("Script not found in bundle.")
            return
        }

        isGenerating = true
        progressText = "Generating 0%"
        
        let convertArg = convertTraditionalToSimplified ? "true" : "false"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonPath)
        process.arguments = [scriptPath, inputURL.path, selectedModel, convertArg]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let fileHandle = pipe.fileHandleForReading
        fileHandle.readabilityHandler = { handle in
            if let line = String(data: handle.availableData, encoding: .utf8) {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                DispatchQueue.main.async {
                    if trimmed.hasPrefix("END:") {
                        let value = trimmed.replacingOccurrences(of: "END:", with: "")
                        if let endTime = Double(value), totalDuration > 0 {
                            let percent = Int((endTime / totalDuration) * 100)
                            progressText = "Generating \(percent)%"
                        }
                    } else {
                        print("LOG: \(trimmed)")
                    }
                }
            }
        }

        DispatchQueue.global().async {
            do {
                try process.run()
                process.waitUntilExit()

                DispatchQueue.main.async {
                    isGenerating = false
                    progressText = "Generate"
                }
                // ✅ Automatically open the input file after generating
                NSWorkspace.shared.open(inputURL.deletingLastPathComponent())
            } catch {
                DispatchQueue.main.async {
                    isGenerating = false
                    progressText = "Failed"
                    print("Failed to run script: \(error.localizedDescription)")
                }
            }
        }
    }

    private func openFilePanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .audio]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            selectedFileURL = panel.url
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            selectedFileURL = url
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}

#Preview {
    ContentView()
}
