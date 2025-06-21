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
    @State private var isHoveringLogo = false

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
            
            HStack {
                Spacer()
                if let logoImage = NSImage(named: "logo-main-white") {
                    Image(nsImage: logoImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                        .scaleEffect(isHoveringLogo ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHoveringLogo)
                        .padding(8)
                        .background(Color.primary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onHover { hovering in
                            isHoveringLogo = hovering
                        }
                        .onTapGesture {
                            if let url = URL(string: "https://editingtools.io/subtitles/") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .help("Open editingtools.io")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(minWidth: 300, idealWidth: 380, maxWidth: 420,
               minHeight: 340, idealHeight: 350, maxHeight: 360)
    }

    /// Returns the total duration (in seconds) of a media file at the given URL.
    /// Uses AVFoundation to asynchronously load the duration of the asset.
    /// Returns nil if the duration can't be loaded.
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
    
    /// Resolves the correct Python interpreter path depending on the environment.
    ///
    /// - If running in development mode (i.e. local machine with `.venv/srt_transcriber_env`), it returns that path.
    /// - If running in production (i.e. inside a packaged `.app`), it returns the path to the bundled virtual environment.
    /// - If neither is found, the app will terminate with a fatal error.
    private func resolvePythonPath() -> String {
        let devPythonPath = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".venv/srt_transcriber_env/bin/python3")
            .path

        if FileManager.default.fileExists(atPath: devPythonPath) {
            print("🔧 Using dev Python path: \(devPythonPath)")
            return devPythonPath
        }

        guard let resourcePath = Bundle.main.resourcePath else {
            fatalError("❌ Could not find bundle resource path.")
        }

        let prodPythonPath = resourcePath + "/srt_transcriber_env/bin/python3"
        print("📦 Using bundled Python path: \(prodPythonPath)")
        return prodPythonPath
    }

    /// Launches the Python transcription script as a subprocess.
    ///
    /// - Validates the selected input media file.
    /// - Resolves the correct Python interpreter path (development or production).
    /// - Executes the `transcribe_to_srt.py` script with the selected file, model, and conversion options.
    /// - Monitors output from the Python script and updates the UI with transcription progress.
    /// - Automatically opens the containing folder when done.
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

        let pythonPath = resolvePythonPath()
        
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
                // Automatically open the input file after generating
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

    /// Opens a file picker dialog to allow the user to select a media file.
    private func openFilePanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .audio]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            selectedFileURL = panel.url
        }
    }

    /// Processes drag-and-drop file input and extracts a valid file URL..
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
