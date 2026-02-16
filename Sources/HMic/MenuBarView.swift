import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = MicViewModel()
    @State private var recordingAction: ShortcutAction?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(16)
            
            Divider()
            
            // Gain Control
            gainControlView
                .padding(16)
            
            // Quick Presets
            presetsView
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            
            Divider()
            
            // Shortcuts Section (Collapsible)
            shortcutsSection
            
            Divider()
            
            // Footer
            footerView
                .padding(12)
        }
        .frame(width: 300)
        .background(.ultraThinMaterial)
        .background(
            ShortcutRecorder(recordingAction: $recordingAction, viewModel: viewModel)
        )
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(spacing: 12) {
            // Animated Icon
            Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                .foregroundStyle(viewModel.isMuted ? .red : .blue)
                .font(.title2)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.deviceName)
                    .font(.headline)
                    .lineLimit(1)
                    .accessibilityLabel("Microphone device: \(viewModel.deviceName)")
                
                Text(viewModel.isMuted ? "Muted" : "Active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(viewModel.isMuted ? "Microphone is muted" : "Microphone is active")
            }
            
            Spacer()
            
            // Mute Toggle
            Toggle("", isOn: Binding(
                get: { !viewModel.isMuted },
                set: { _ in viewModel.toggleMute() }
            ))
            .toggleStyle(.switch)
            .accessibilityLabel("Mute microphone")
        }
    }
    
    // MARK: - Gain Control
    
    private var gainControlView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Input Gain")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.inputGain.toPercentageString())
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.primary)
                    Text(viewModel.inputGain.toDecibelsString())
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            
            // Visual Level Indicator
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(.quaternary)
                    
                    // Level bar
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.green, .yellow, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(viewModel.inputGain))
                }
            }
            .frame(height: 6)
            
            // Slider
            Slider(
                value: Binding(
                    get: { viewModel.inputGain },
                    set: { viewModel.setGain($0) }
                ),
                in: 0...1
            ) { isEditing in
                viewModel.isDragging = isEditing
            }
            .accessibilityLabel("Input gain slider")
            .accessibilityValue("\(Int(viewModel.inputGain * 100)) percent")
        }
    }
    
    // MARK: - Quick Presets
    
    private var presetsView: some View {
        HStack(spacing: 8) {
            Text("Quick:")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { preset in
                Button(action: {
                    viewModel.setPresetGain(Float(preset))
                }) {
                    Text("\(Int(preset * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(viewModel.inputGain == Float(preset) ? .blue : .gray)
            }
        }
    }
    
    // MARK: - Shortcuts Section
    
    private var shortcutsSection: some View {
        DisclosureGroup("Shortcuts", isExpanded: $viewModel.showingShortcuts) {
            VStack(spacing: 10) {
                ForEach(ShortcutAction.allCases, id: \.self) { action in
                    HStack {
                        Text(action.rawValue)
                            .font(.caption)
                        
                        Spacer()
                        
                        Button(action: {
                            recordingAction = action
                        }) {
                            if recordingAction == action {
                                HStack(spacing: 4) {
                                    Image(systemName: "record.circle")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.red)
                                    Text("Recording...")
                                        .foregroundStyle(.red)
                                }
                            } else {
                                Text(viewModel.shortcutDescription(for: action))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        if viewModel.shortcuts[action] != nil {
                            Button(action: {
                                viewModel.clearShortcut(for: action)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Shortcut Recorder

struct ShortcutRecorder: NSViewRepresentable {
    @Binding var recordingAction: ShortcutAction?
    var viewModel: MicViewModel
    
    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.onKeyDown = { event in
            if let action = recordingAction {
                viewModel.recordShortcut(for: action, event: event)
                recordingAction = nil
                return true
            }
            return false
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if recordingAction != nil {
            nsView.window?.makeFirstResponder(nsView)
        }
    }
    
    class KeyView: NSView {
        var onKeyDown: ((NSEvent) -> Bool)?
        
        override var acceptsFirstResponder: Bool { true }
        
        override func keyDown(with event: NSEvent) {
            if let onKeyDown = onKeyDown, onKeyDown(event) {
                return
            }
            super.keyDown(with: event)
        }
    }
}
