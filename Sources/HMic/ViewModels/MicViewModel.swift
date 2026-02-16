import Foundation
import Combine
import SwiftUI
import Carbon

class MicViewModel: ObservableObject {
    @Published var inputGain: Float = 0.0
    @Published var isMuted: Bool = false
    @Published var deviceName: String = "Loading..."
    @Published var shortcuts: [ShortcutAction: SavedShortcut] = [:]
    @Published var errorMessage: String?
    @Published var showingShortcuts: Bool = false
    @Published var currentAudioLevel: Float = 0.0  // Real-time audio level
    
    var isDragging: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let micService = MicrophoneService.shared
    private let shortcutService = ShortcutService.shared
    
    init() {
        setupBindings()
        micService.requestAccess()
    }
    
    private func setupBindings() {
        micService.$currentInputGain
            .receive(on: RunLoop.main)
            .sink { [weak self] newGain in
                guard let self = self, !self.isDragging else { return }
                self.inputGain = newGain
            }
            .store(in: &cancellables)
            
        micService.$isMuted
            .receive(on: RunLoop.main)
            .assign(to: \.isMuted, on: self)
            .store(in: &cancellables)
            
        micService.$deviceName
            .receive(on: RunLoop.main)
            .assign(to: \.deviceName, on: self)
            .store(in: &cancellables)
            
        micService.$currentAudioLevel
            .receive(on: RunLoop.main)
            .assign(to: \.currentAudioLevel, on: self)
            .store(in: &cancellables)
            
        shortcutService.$shortcuts
            .receive(on: RunLoop.main)
            .assign(to: \.shortcuts, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Gain Control
    
    func setGain(_ gain: Float) {
        inputGain = gain
        micService.setGain(gain)
    }
    
    func setPresetGain(_ preset: Float) {
        setGain(preset)
    }
    
    // MARK: - Mute Control
    
    func toggleMute() {
        micService.toggleMute()
    }
    
    // MARK: - Shortcuts
    
    func recordShortcut(for action: ShortcutAction, event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue
        let keyCode = UInt32(event.keyCode)
        
        shortcutService.saveShortcut(action: action, keyCode: keyCode, modifiers: UInt32(modifiers))
    }
    
    func clearShortcut(for action: ShortcutAction) {
        shortcutService.removeShortcut(action: action)
    }
    
    func shortcutDescription(for action: ShortcutAction) -> String {
        guard let shortcut = shortcuts[action] else { return "None" }
        return "\(modifierString(shortcut.modifiers))\(keyString(shortcut.keyCode))"
    }
    
    private func modifierString(_ modifiers: UInt32) -> String {
        var result = ""
        let flags = NSEvent.ModifierFlags(rawValue: UInt(modifiers))
        if flags.contains(.control) { result += "⌃" }
        if flags.contains(.option) { result += "⌥" }
        if flags.contains(.shift) { result += "⇧" }
        if flags.contains(.command) { result += "⌘" }
        return result
    }
    
    private func keyString(_ keyCode: UInt32) -> String {
        // Common key mappings
        switch keyCode {
        case 0: return "A"; case 1: return "S"; case 2: return "D"; case 3: return "F"
        case 4: return "H"; case 5: return "G"; case 6: return "Z"; case 7: return "X"
        case 8: return "C"; case 9: return "V"; case 11: return "B"; case 12: return "Q"
        case 13: return "W"; case 14: return "E"; case 15: return "R"; case 16: return "Y"
        case 17: return "T"; case 31: return "O"; case 32: return "U"; case 34: return "I"
        case 35: return "P"; case 37: return "L"; case 38: return "J"; case 40: return "K"
        case 45: return "N"; case 46: return "M"
        case 18: return "1"; case 19: return "2"; case 20: return "3"; case 21: return "4"
        case 23: return "5"; case 22: return "6"; case 26: return "7"; case 28: return "8"
        case 25: return "9"; case 29: return "0"
        case 36: return "↩"; case 49: return "Space"; case 51: return "⌫"
        default: return "Key\(keyCode)"
        }
    }
}
